package com.ezev.servlets;

import com.ezev.entities.Station;
import com.ezev.helper.FactoryProvider;
import com.ezev.helper.GeminiHelper;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/PlanRouteServlet")
public class PlanRouteServlet extends HttpServlet {

    // ✅ All stationCategory values to EXCLUDE from route planning
    // Based on your DB: RESIDENTIAL = home chargers, private use only
    private static final Set<String> EXCLUDED_CATEGORIES = new HashSet<>(Arrays.asList(
            "RESIDENTIAL",
            "residential",
            "Residential",
            "PRIVATE",
            "private",
            "Private",
            "HOME",
            "home",
            "Home"
    ));

    // ✅ Connector types that are ONLY for home/residential use
    private static final Set<String> RESIDENTIAL_CONNECTORS = new HashSet<>(Arrays.asList(
            "Wall Socket",
            "wall socket",
            "WALL_SOCKET",
            "Three-Pin Plug",
            "three-pin plug"
    ));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Gson gson = new Gson();
        Map<String, Object> result = new HashMap<>();
        Session session = null;

        try {
            // 1. Parameters
            String vehicleModel  = request.getParameter("vehicleModel");
            int maxRange         = Integer.parseInt(request.getParameter("maxRange"));
            int batteryLevel     = Integer.parseInt(request.getParameter("batteryLevel"));
            String startLocation = request.getParameter("startLocation").trim();
            String destination   = request.getParameter("destination").trim();

            System.out.println("\n=== ROUTE PLANNING REQUEST ===");
            System.out.println("From: " + startLocation + "  →  To: " + destination);
            System.out.println("Vehicle: " + vehicleModel
                    + " | MaxRange: " + maxRange
                    + " | Battery: " + batteryLevel + "%");

            int currentRange = (maxRange * batteryLevel) / 100;
            System.out.println("Current Range: " + currentRange + " km");

            // 2. DB session
            session = FactoryProvider.getFactory().openSession();

            // 3. Load ONLY public/commercial active stations
            //    ✅ Filter out RESIDENTIAL at the DB query level (most efficient)
            List<Station> allStations = session.createQuery(
                    "FROM Station WHERE status = 'Active' " +
                    "AND (stationCategory IS NULL " +
                    "OR (stationCategory != 'RESIDENTIAL' " +
                    "AND stationCategory != 'Residential' " +
                    "AND stationCategory != 'residential' " +
                    "AND stationCategory != 'PRIVATE' " +
                    "AND stationCategory != 'Private' " +
                    "AND stationCategory != 'private' " +
                    "AND stationCategory != 'HOME' " +
                    "AND stationCategory != 'Home' " +
                    "AND stationCategory != 'home'))",
                    Station.class
            ).list();

            System.out.println("Public/Commercial active stations: " + allStations.size());

            // 4. Also filter in Java for connector type safety
            //    Wall Socket = home charger, never appropriate for EV highway stops
            List<Station> publicStations = new ArrayList<>();
            int filteredOut = 0;

            for (Station st : allStations) {
                // Double-check category
                String cat = st.getStationCategory();
                if (cat != null && EXCLUDED_CATEGORIES.contains(cat.trim())) {
                    filteredOut++;
                    continue;
                }

                // Filter out wall socket / residential connector types
                String connector = st.getConnectorType();
                if (connector != null && RESIDENTIAL_CONNECTORS.contains(connector.trim())) {
                    filteredOut++;
                    System.out.println("  Skipped residential connector: "
                            + st.getStationName() + " | " + connector);
                    continue;
                }

                // Filter by station name keywords (catches "Varun Home", "My Home", etc.)
                String name = st.getStationName() != null
                        ? st.getStationName().toLowerCase() : "";
                if (name.contains(" home") || name.endsWith("home")
                        || name.contains("residence") || name.contains("residential")
                        || name.contains("private charging")) {
                    filteredOut++;
                    System.out.println("  Skipped private by name: " + st.getStationName());
                    continue;
                }

                publicStations.add(st);
            }

            System.out.println("After filtering private/residential: "
                    + publicStations.size() + " stations ("
                    + filteredOut + " removed)");

            if (publicStations.isEmpty()) {
                sendError(result, "No public charging stations found in database.", response, gson);
                return;
            }

            // 5. Find city center coordinates from DB
            double[] startCoords = findCityCenter(startLocation, publicStations);
            double[] destCoords  = findCityCenter(destination, publicStations);

            System.out.println("Start '" + startLocation + "': " + coordStr(startCoords));
            System.out.println("Dest  '" + destination   + "': " + coordStr(destCoords));

            if (startCoords == null) {
                sendError(result, "No public stations found in DB for: \"" + startLocation
                        + "\". Check spelling matches your station addresses.", response, gson);
                return;
            }
            if (destCoords == null) {
                sendError(result, "No public stations found in DB for: \"" + destination
                        + "\". Check spelling matches your station addresses.", response, gson);
                return;
            }

            // 6. Groq AI for advisory waypoints
            String aiResponse = GeminiHelper.planRoute(
                    startLocation, destination, vehicleModel, maxRange, currentRange, "");
            System.out.println("AI Waypoints: "
                    + (aiResponse != null ? aiResponse : "null → DB corridor only"));

            // 7. Total route distance
            double totalKm = haversine(
                    startCoords[0], startCoords[1],
                    destCoords[0],  destCoords[1]);
            System.out.println("Total route: " + Math.round(totalKm) + " km");

            // 8. Calculate ideal stops
            int idealStops = (int) Math.ceil(totalKm / (maxRange * 0.80)) - 1;
            idealStops = Math.max(3, Math.min(idealStops, 10));
            System.out.println("Ideal stops: " + idealStops);

            // 9. Corridor width
            double corridorKm = Math.min(80.0, totalKm * 0.12);
            corridorKm = Math.max(50.0, corridorKm);
            System.out.println("Corridor width: " + Math.round(corridorKm) + " km");

            // 10. Filter stations in route corridor
            List<StationDist> corridor = new ArrayList<>();

            for (Station st : publicStations) {
                double lat = st.getLatitude();
                double lon = st.getLongitude();
                if (lat == 0.0 && lon == 0.0) continue;

                double perpDist = perpDistance(startCoords, destCoords, lat, lon);
                if (perpDist > corridorKm) continue;

                double proj = projection(startCoords, destCoords, lat, lon);
                if (proj < 0.05 || proj > 0.95) continue;

                double distFromStart = haversine(startCoords[0], startCoords[1], lat, lon);
                if (distFromStart < 30.0) continue;

                double distFromDest = haversine(destCoords[0], destCoords[1], lat, lon);
                if (distFromDest < 25.0) continue;

                corridor.add(new StationDist(st, distFromStart, perpDist, proj, perpDist));
            }

            System.out.println("Public stations in corridor: " + corridor.size());

            // 11. Sort by distance from start
            corridor.sort((a, b) -> Double.compare(a.distFromStart, b.distFromStart));

            // 12. Segment-based selection (primary)
            List<Station> selected = pickStationsPerSegment(corridor, totalKm, idealStops);
            System.out.println("Selected (segment): " + selected.size());

            // 13. Spacing fallback
            if (selected.size() < Math.min(idealStops, 3)) {
                System.out.println("Fallback to spacing method...");
                selected = pickStationsBySpacing(corridor, totalKm, idealStops);
                System.out.println("Selected (spacing): " + selected.size());
            }

            // 14. Widen corridor if still too few
            if (selected.isEmpty() && corridorKm < 150) {
                System.out.println("Widening corridor to 150km...");
                List<StationDist> wide = new ArrayList<>();

                for (Station st : publicStations) {
                    double lat = st.getLatitude();
                    double lon = st.getLongitude();
                    if (lat == 0.0 && lon == 0.0) continue;

                    double perpDist = perpDistance(startCoords, destCoords, lat, lon);
                    if (perpDist > 150.0) continue;

                    double proj = projection(startCoords, destCoords, lat, lon);
                    if (proj < 0.03 || proj > 0.97) continue;

                    double dist = haversine(startCoords[0], startCoords[1], lat, lon);
                    if (dist < 20.0) continue;

                    wide.add(new StationDist(st, dist, perpDist, proj, perpDist));
                }

                wide.sort((a, b) -> Double.compare(a.distFromStart, b.distFromStart));
                selected = pickStationsBySpacing(wide, totalKm, idealStops);
                System.out.println("Wide corridor selected: " + selected.size());
            }

            if (selected.isEmpty()) {
                sendError(result,
                        "No public charging stations found along the route from "
                        + startLocation + " to " + destination + ".",
                        response, gson);
                return;
            }

            // 15. Sort final by distance from start
            selected.sort((a, b) -> {
                double dA = haversine(startCoords[0], startCoords[1],
                        a.getLatitude(), a.getLongitude());
                double dB = haversine(startCoords[0], startCoords[1],
                        b.getLatitude(), b.getLongitude());
                return Double.compare(dA, dB);
            });

            System.out.println("=== FINAL CHARGING STOPS ===");
            for (Station st : selected) {
                double d = haversine(startCoords[0], startCoords[1],
                        st.getLatitude(), st.getLongitude());
                System.out.println("  " + Math.round(d) + "km | "
                        + st.getStationName()
                        + " [" + st.getStationCategory() + "]"
                        + " | " + st.getConnectorType()
                        + " | " + st.getStationAddress());
            }

            // 16. Build response
            List<Map<String, Object>> stationList = new ArrayList<>();
            for (Station st : selected) {
                Map<String, Object> sd = new HashMap<>();
                double dist = haversine(startCoords[0], startCoords[1],
                        st.getLatitude(), st.getLongitude());
                sd.put("id",                st.getStationId());
                sd.put("name",              st.getStationName());
                sd.put("address",           st.getStationAddress());
                sd.put("latitude",          st.getLatitude());
                sd.put("longitude",         st.getLongitude());
                sd.put("connectorType",     st.getConnectorType());
                sd.put("price",             st.getPricePerUnit());
                sd.put("category",          st.getStationCategory());
                sd.put("distanceFromStart", Math.round(dist));
                sd.put("estimatedCost",     chargingCost(st.getPricePerUnit(), maxRange));
                stationList.add(sd);
            }

            double totalCost = stationList.stream()
                    .mapToDouble(s -> ((Number) s.get("estimatedCost")).doubleValue()).sum();

            result.put("success",       true);
            result.put("totalDistance", (int) totalKm);
            result.put("estimatedCost", Math.round(totalCost));
            result.put("stations",      stationList);
            result.put("stationCount",  selected.size());
            result.put("confidence",    selected.size() >= idealStops ? "High" : "Medium");
            result.put("aiSuggestion",
                    aiResponse != null ? aiResponse : "DB corridor search");

            System.out.println("✅ Done: " + selected.size()
                    + " public stations for " + Math.round(totalKm) + "km route");

        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Failed to calculate route: " + e.getMessage());
        } finally {
            if (session != null && session.isOpen()) session.close();
        }

        response.getWriter().write(gson.toJson(result));
    }

    // ═══════════════════════════════════════════════════════════
    // STATION SELECTION
    // ═══════════════════════════════════════════════════════════

    /** Pick best (closest to route line) station per route segment */
    private List<Station> pickStationsPerSegment(
            List<StationDist> corridor, double totalKm, int numSegments) {

        List<Station> result = new ArrayList<>();

        for (int seg = 0; seg < numSegments; seg++) {
            double segStart = (double) seg       / numSegments;
            double segEnd   = (double)(seg + 1)  / numSegments;

            StationDist best = null;
            for (StationDist sd : corridor) {
                if (sd.proj >= segStart && sd.proj < segEnd) {
                    if (best == null || sd.score < best.score) {
                        best = sd;
                    }
                }
            }

            if (best != null) {
                result.add(best.station);
                System.out.println("  Seg " + (seg + 1) + "/"
                        + numSegments + " ("
                        + Math.round(segStart * totalKm) + "-"
                        + Math.round(segEnd * totalKm) + "km): "
                        + best.station.getStationName()
                        + " [" + best.station.getStationCategory() + "]"
                        + " perp=" + Math.round(best.perpDist) + "km");
            }
        }

        return result;
    }

    /** Spacing-based fallback selection */
    private List<Station> pickStationsBySpacing(
            List<StationDist> corridor, double totalKm, int idealStops) {

        double minSpacing = Math.max(40.0, totalKm / (idealStops + 2));
        List<Station> result = new ArrayList<>();

        for (StationDist sd : corridor) {
            if (result.size() >= idealStops + 2) break;

            boolean tooClose = false;
            for (Station sel : result) {
                double d = haversine(
                        sd.station.getLatitude(), sd.station.getLongitude(),
                        sel.getLatitude(), sel.getLongitude());
                if (d < minSpacing) { tooClose = true; break; }
            }

            if (!tooClose) result.add(sd.station);
        }

        return result;
    }

    // ═══════════════════════════════════════════════════════════
    // CITY DETECTION — 100% FROM DB
    // ═══════════════════════════════════════════════════════════

    private double[] findCityCenter(String cityName, List<Station> stations) {
        if (cityName == null || cityName.trim().isEmpty()) return null;

        for (String term : getCityAliases(cityName)) {
            double[] coords = searchByTerm(term, stations);
            if (coords != null) return coords;
        }

        System.out.println("  No DB match for: " + cityName);
        return null;
    }

    private double[] searchByTerm(String term, List<Station> stations) {
        String search = term.toLowerCase().trim();
        List<double[]> matches = new ArrayList<>();

        for (Station st : stations) {
            String addr = st.getStationAddress() != null
                    ? st.getStationAddress().toLowerCase() : "";
            String name = st.getStationName() != null
                    ? st.getStationName().toLowerCase() : "";

            if (cityMatch(addr, search) || cityMatch(name, search)) {
                double lat = st.getLatitude();
                double lon = st.getLongitude();
                if (lat != 0.0 || lon != 0.0) {
                    matches.add(new double[]{lat, lon});
                }
            }
        }

        if (matches.isEmpty()) return null;

        double avgLat = matches.stream().mapToDouble(c -> c[0]).average().orElse(0);
        double avgLon = matches.stream().mapToDouble(c -> c[1]).average().orElse(0);
        System.out.println("  DB: " + matches.size()
                + " public stations for '" + term + "' → ["
                + String.format("%.4f", avgLat) + ", "
                + String.format("%.4f", avgLon) + "]");
        return new double[]{avgLat, avgLon};
    }

    /**
     * Matches city in last 2 comma-segments of address.
     * Open Charge Map format: "Street, Area, City" — city is always last.
     */
    private boolean cityMatch(String address, String city) {
        if (address == null || city == null) return false;
        String[] parts = address.split(",");

        for (int i = Math.max(0, parts.length - 2); i < parts.length; i++) {
            String seg = parts[i].trim();
            if (seg.equals(city)
                    || seg.startsWith(city + " ")
                    || seg.endsWith(" " + city)
                    || seg.contains(" " + city + " ")) {
                return true;
            }
        }

        return address.matches(".*\\b"
                + java.util.regex.Pattern.quote(city) + "\\b.*");
    }

    private List<String> getCityAliases(String cityName) {
        List<String> terms = new ArrayList<>();
        String lower = cityName.toLowerCase().trim();
        terms.add(lower);

        Map<String, List<String>> aliases = new HashMap<>();
        aliases.put("delhi",     List.of("delhi", "new delhi"));
        aliases.put("new delhi", List.of("new delhi", "delhi"));
        aliases.put("mumbai",    List.of("mumbai", "bombay"));
        aliases.put("bombay",    List.of("mumbai", "bombay"));
        aliases.put("bangalore", List.of("bangalore", "bengaluru"));
        aliases.put("bengaluru", List.of("bengaluru", "bangalore"));
        aliases.put("chennai",   List.of("chennai", "madras"));
        aliases.put("kolkata",   List.of("kolkata", "calcutta"));
        aliases.put("kochi",     List.of("kochi", "cochin", "ernakulam"));
        aliases.put("goa",       List.of("goa", "panaji", "vasco da gama"));

        if (aliases.containsKey(lower)) {
            for (String a : aliases.get(lower)) {
                if (!terms.contains(a)) terms.add(a);
            }
        }
        return terms;
    }

    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════

    private static class StationDist {
        Station station;
        double distFromStart;
        double perpDist;
        double proj;
        double score;

        StationDist(Station s, double dist, double perp, double proj, double score) {
            this.station = s;
            this.distFromStart = dist;
            this.perpDist = perp;
            this.proj = proj;
            this.score = score;
        }
    }

    private double haversine(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private double perpDistance(double[] start, double[] end, double lat, double lon) {
        double x1 = start[0], y1 = start[1];
        double x2 = end[0],   y2 = end[1];
        double num = Math.abs((y2 - y1) * lat - (x2 - x1) * lon + x2 * y1 - y2 * x1);
        double den = Math.sqrt(Math.pow(y2 - y1, 2) + Math.pow(x2 - x1, 2));
        if (den == 0) return 0;
        return (num / den) * 111.0;
    }

    private double projection(double[] start, double[] end, double lat, double lon) {
        double ax = end[0] - start[0];
        double ay = end[1] - start[1];
        double bx = lat    - start[0];
        double by = lon    - start[1];
        double dot = bx * ax + by * ay;
        double len = ax * ax + ay * ay;
        if (len == 0) return 0;
        return dot / len;
    }

    private double chargingCost(double pricePerUnit, int batteryCapacity) {
        return (batteryCapacity * 0.6) * pricePerUnit;
    }

    private String coordStr(double[] c) {
        if (c == null) return "NOT FOUND";
        return "[" + String.format("%.4f", c[0])
                + ", " + String.format("%.4f", c[1]) + "]";
    }

    private void sendError(Map<String, Object> result, String msg,
            HttpServletResponse response, Gson gson) throws IOException {
        result.put("success", false);
        result.put("message", msg);
        response.getWriter().write(gson.toJson(result));
    }
}
