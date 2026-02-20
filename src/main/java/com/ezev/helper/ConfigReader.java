package com.ezev.helper;

import java.io.InputStream;
import java.util.Properties;

public class ConfigReader {
    
    private static Properties props = new Properties();
    
    // This runs once when class loads
    static {
        try {
            InputStream input = ConfigReader.class
                .getClassLoader()
                .getResourceAsStream("config.properties");
            
            if (input != null) {
                props.load(input);
                System.out.println("✅ Config loaded successfully");
            } else {
                System.err.println("❌ config.properties not found!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Call this method anywhere to get a value
    public static String get(String key) {
        return props.getProperty(key);
    }
}