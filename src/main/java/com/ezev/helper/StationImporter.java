package com.ezev.helper;

import com.ezev.entities.Station;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class StationImporter {

    // --- CONFIGURATION ---
    
    // 1. PASTE YOUR API KEY HERE
   private static final String API_KEY = ConfigReader.get("OPENCHARGE_API_KEY"); 
    
    // 2. API URL (ALL INDIA)
    // countrycode=IN : India
    // maxresults=1000 : Fetch up to 1000 stations
    private static final String API_URL = "https://api.openchargemap.io/v3/poi/?output=json&countrycode=IN&maxresults=1000";

    public static void main(String[] args) {
        importStations();
    }

    public static void importStations() {
        try {
            System.out.println("Connecting to Open Charge Map (fetching All India data)...");
            
            // Create URL using URI to avoid deprecated warning
            URL url = java.net.URI.create(API_URL + "&key=" + API_KEY).toURL();
            
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "EZEV-Project");

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                System.out.println("Error: Could not connect (Code: " + responseCode + ")");
                return;
            }

            // Read the Response
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder jsonText = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) jsonText.append(line);
            br.close();

            // Parse JSON
            JsonArray stationsArray = JsonParser.parseString(jsonText.toString()).getAsJsonArray();
            System.out.println("Found " + stationsArray.size() + " stations across India. Saving to database...");

            Session s = FactoryProvider.getFactory().openSession();
            Transaction tx = s.beginTransaction();

            int savedCount = 0;
            for (JsonElement element : stationsArray) {
                try {
                    JsonObject obj = element.getAsJsonObject();
                    
                    // --- 1. GET ADDRESS INFO ---
                    JsonObject addressInfo = obj.getAsJsonObject("AddressInfo");
                    
                    String name = "Unknown Station";
                    if (addressInfo.has("Title") && !addressInfo.get("Title").isJsonNull()) {
                        name = addressInfo.get("Title").getAsString();
                    }

                    double lat = addressInfo.get("Latitude").getAsDouble();
                    double lon = addressInfo.get("Longitude").getAsDouble();
                    
                    String address = "India";
                    if (addressInfo.has("AddressLine1") && !addressInfo.get("AddressLine1").isJsonNull()) {
                        address = addressInfo.get("AddressLine1").getAsString();
                    }
                    if (addressInfo.has("Town") && !addressInfo.get("Town").isJsonNull()) {
                        address += ", " + addressInfo.get("Town").getAsString();
                    }

                    // --- 2. GET PROVIDER (Tata, Ather, etc) ---
                    String provider = "Unknown Network";
                    if (obj.has("OperatorInfo") && !obj.get("OperatorInfo").isJsonNull()) {
                         JsonObject opInfo = obj.getAsJsonObject("OperatorInfo");
                         if (opInfo.has("Title") && !opInfo.get("Title").isJsonNull()) {
                             provider = opInfo.get("Title").getAsString();
                         }
                    }

                    // --- 3. SAVE TO DB ---
                    Station st = new Station();
                    st.setStationName(name);
                    st.setStationAddress(address);
                    st.setLatitude(lat);
                    st.setLongitude(lon);
                    
                    // Standard Fields for Imported Data
                    st.setStationCategory("COMMERCIAL");
                    st.setOwnerId(0);
                    st.setProviderName(provider);
                    st.setConnectorType("CCS2 / Type 2");
                    st.setPricePerUnit(18.0); // Default market rate
                    st.setStatus("Active");
                    st.setStationDescription("Imported from OpenChargeMap API");
                    st.setStationImage("default_station.png");

                    s.persist(st);
                    savedCount++;
                    
                } catch (Exception innerEx) {
                    // Skip bad data without stopping the loop
                    System.out.println("Skipped one bad entry.");
                }
            }

            tx.commit();
            s.close();
            System.out.println("SUCCESS! Saved " + savedCount + " stations from across India.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}