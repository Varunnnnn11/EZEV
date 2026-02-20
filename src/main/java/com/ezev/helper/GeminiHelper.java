package com.ezev.helper;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class GeminiHelper {

    // ✅ Free API key from: https://console.groq.com/
   private static final String API_KEY = ConfigReader.get("GROQ_API_KEY");

    // Groq API endpoint (OpenAI-compatible)
    private static final String API_URL = "https://api.groq.com/openai/v1/chat/completions";

    // Groq free models - tried in order
    private static final String[] MODELS = {
        "llama-3.3-70b-versatile",  // Best quality
        "llama-3.1-8b-instant",     // Fastest
        "mixtral-8x7b-32768"        // Fallback
    };

    /**
     * Asks Groq AI to suggest intermediate waypoint cities along the route.
     * Returns comma-separated city names e.g. "Ujjain, Gwalior, Agra"
     * Returns null if all models fail — servlet handles null gracefully.
     */
    public static String planRoute(String startLocation, String destination,
            String vehicleModel, int maxRange, int currentRange, String stationsJson) {

        for (String model : MODELS) {
            try {
                System.out.println("🔄 Trying Groq model: " + model);
                String result = callGroqAPI(model, startLocation, destination,
                        vehicleModel, maxRange, currentRange);

                if (result != null && !result.startsWith("Error")) {
                    System.out.println("✅ Groq Success: " + model + " → " + result);
                    return result;
                }

                System.out.println("❌ " + model + " failed, trying next...");

            } catch (Exception e) {
                System.err.println("❌ Error with " + model + ": " + e.getMessage());
            }
        }

        // Return null — PlanRouteServlet will use pure DB corridor search
        System.err.println("⚠️ All Groq models failed. Using DB corridor only.");
        return null;
    }

    private static String callGroqAPI(String model, String startLocation,
            String destination, String vehicleModel, int maxRange, int currentRange) {
        try {
            System.out.println("=== ⚡ GROQ API CALL ===");
            System.out.println("Model: " + model + " | Route: "
                    + startLocation + " → " + destination);

            String prompt = String.format(
                    "Plan an EV charging route for India.\n"
                    + "START: %s\n"
                    + "DESTINATION: %s\n"
                    + "VEHICLE: %s | MAX RANGE: %d km | CURRENT: %d km\n\n"
                    + "List 3-5 Indian cities along the highway route for charging stops.\n"
                    + "RULES: 150-250km apart | major highways only | "
                    + "exclude start and destination | commas only | no extra text.\n"
                    + "Example: Ujjain, Gwalior, Agra\n"
                    + "RESPONSE:",
                    startLocation, destination, vehicleModel, maxRange, currentRange
            );

            JsonObject body = new JsonObject();
            body.addProperty("model", model);
            body.addProperty("max_tokens", 100);
            body.addProperty("temperature", 0.2);

            JsonArray messages = new JsonArray();

            JsonObject sys = new JsonObject();
            sys.addProperty("role", "system");
            sys.addProperty("content",
                    "You are an EV route planner for India. "
                    + "Respond ONLY with city names separated by commas. "
                    + "No other text.");
            messages.add(sys);

            JsonObject user = new JsonObject();
            user.addProperty("role", "user");
            user.addProperty("content", prompt);
            messages.add(user);

            body.add("messages", messages);

            URL url = new URL(API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
            conn.setDoOutput(true);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.toString().getBytes("utf-8"));
            }

            int code = conn.getResponseCode();
            System.out.println("Response Code: " + code);

            if (code != 200) {
                BufferedReader err = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream()));
                StringBuilder errBody = new StringBuilder();
                String line;
                while ((line = err.readLine()) != null) errBody.append(line);
                System.err.println("Error: " + errBody);
                return "Error: " + code;
            }

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream()));
            StringBuilder resp = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) resp.append(line);
            br.close();

            // Parse: { "choices": [ { "message": { "content": "city1, city2" } } ] }
            JsonObject json = JsonParser.parseString(resp.toString()).getAsJsonObject();

            if (json.has("choices") && json.getAsJsonArray("choices").size() > 0) {
                String text = json.getAsJsonArray("choices")
                        .get(0).getAsJsonObject()
                        .getAsJsonObject("message")
                        .get("content").getAsString();

                // Clean up
                text = text.trim()
                        .replaceAll("\\s+", " ")
                        .replaceAll("\\n+", ", ")
                        .replaceAll("[\\[\\]\"{}*#]", "")
                        .replaceAll("(?i)response:|cities:|route:", "")
                        .trim();

                return text;
            }

            return "Error: empty response";

        } catch (Exception e) {
            System.err.println("❌ Groq exception: " + e.getMessage());
            return "Error: " + e.getMessage();
        }
    }
}
