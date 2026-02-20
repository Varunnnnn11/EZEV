package com.ezev.helper;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class FactoryProvider {
    
    // 1. Create a variable to hold the Factory (The Oven)
    // We make it 'static' so it belongs to the whole project, not just one user.
    private static SessionFactory factory;

    // 2. Create a method to give us the Factory whenever we need it
    public static SessionFactory getFactory() {
        
        try {
            // Check: Is the variable empty? (Is the Oven built yet?)
            if (factory == null) {
                
                // If it's empty, build it now!
                factory = new Configuration()
                        .configure("hibernate.cfg.xml") // Read our settings file
                        .buildSessionFactory();         // Build the connection
            }
            
        } catch (Exception e) {
            e.printStackTrace(); // If something breaks, print the error
        }
        
        // Return the ready-to-use factory
        return factory;
    }
}