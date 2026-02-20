package com.ezev.servlets;

import com.ezev.entities.Station;
import com.ezev.entities.User;
import com.ezev.helper.FactoryProvider;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "AddStationServlet", urlPatterns = {"/AddStationServlet"})
public class AddStationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. GET LOGGED-IN USER
            HttpSession httpSession = request.getSession();
            User user = (User) httpSession.getAttribute("currentUser");

            if (user == null) {
                httpSession.setAttribute("message", "Session Expired! Please login.");
                response.sendRedirect("Login.jsp");
                return;
            }

            // 2. FETCH FORM DATA
            String category = request.getParameter("stationCategory"); // "RESIDENTIAL" or "COMMERCIAL"
            String name = request.getParameter("stationName");
            String address = request.getParameter("stationAddress");
            String connector = request.getParameter("connectorType");
            String description = request.getParameter("stationDescription");
            
            // Parse numbers (Handle potential empty strings safely)
            double lat = Double.parseDouble(request.getParameter("latitude"));
            double lng = Double.parseDouble(request.getParameter("longitude"));
            double price = Double.parseDouble(request.getParameter("pricePerUnit"));
            
            // 3. DETERMINE OWNER & PROVIDER LOGIC
            int ownerId = 0;
            String providerName = "";

            if ("RESIDENTIAL".equalsIgnoreCase(category)) {
                // Private Charger: Linked to the User
                ownerId = user.getUserId();
                providerName = user.getUserName(); // Provider is the User themselves
            } else {
                // Commercial Charger: No specific owner ID, Provider comes from form
                ownerId = 0;
                providerName = request.getParameter("providerName"); 
                if(providerName == null) providerName = "Commercial Network";
            }

            // 4. CREATE STATION OBJECT
            Station s = new Station();
            s.setStationName(name);
            s.setStationAddress(address);
            s.setStationCategory(category);
            s.setOwnerId(ownerId);
            s.setProviderName(providerName);
            s.setConnectorType(connector);
            s.setStationDescription(description);
            s.setLatitude(lat);
            s.setLongitude(lng);
            s.setPricePerUnit(price);
            s.setStatus("Active"); // Default to Active
            s.setStationImage("default_home_charger.png"); // Placeholder image

            // 5. SAVE TO DATABASE (Hibernate)
            Session hibernateSession = FactoryProvider.getFactory().openSession();
            Transaction tx = hibernateSession.beginTransaction();

            hibernateSession.persist(s);

            tx.commit();
            hibernateSession.close();

            // 6. SUCCESS MESSAGE & REDIRECT
            httpSession.setAttribute("message", "✅ Charger Added Successfully! Thank you for hosting.");
            response.sendRedirect("Dashboard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("message", "❌ Error adding station: " + e.getMessage());
            response.sendRedirect("AddCharger.jsp");
        }
    }
}