package com.ezev.servlets;

import com.ezev.entities.Booking;
import com.ezev.entities.Station;
import com.ezev.entities.User;
import com.ezev.helper.FactoryProvider;
import com.ezev.helper.EmailSender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession httpSession = request.getSession();
        User user = (User) httpSession.getAttribute("currentUser");
        
        // 1. Security Check
        if (user == null) {
            httpSession.setAttribute("message", "Please login first!");
            response.sendRedirect("Login.jsp");
            return;
        }
        
        Session hibernateSession = null;
        Transaction tx = null;
        
        try {
            // 2. Get Form Parameters
            int stationId = Integer.parseInt(request.getParameter("stationId"));
            String bookingDateStr = request.getParameter("bookingDate"); // "2026-02-10"
            String bookingTime = request.getParameter("bookingTime"); // "14:30"
            String vehicleModel = request.getParameter("vehicleModel");
            String vehicleNumber = request.getParameter("vehicleNumber");
            String batteryCapacityStr = request.getParameter("batteryCapacity");
            double amount = Double.parseDouble(request.getParameter("amount"));
            
            System.out.println("=== BOOKING REQUEST ===");
            System.out.println("User: " + user.getUserName());
            System.out.println("Station ID: " + stationId);
            System.out.println("Date: " + bookingDateStr);
            System.out.println("Time: " + bookingTime);
            System.out.println("Vehicle: " + vehicleModel);
            System.out.println("Amount: ₹" + amount);
            
            // 3. Parse Date
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Date bookingDate = dateFormat.parse(bookingDateStr);
            
            // 4. Parse Battery Capacity (optional)
            Double batteryCapacity = null;
            if (batteryCapacityStr != null && !batteryCapacityStr.trim().isEmpty()) {
                batteryCapacity = Double.valueOf(batteryCapacityStr);
            }
            
            // 5. Open Hibernate Session
            hibernateSession = FactoryProvider.getFactory().openSession();
            tx = hibernateSession.beginTransaction();
            
            // 6. Get Station from Database
            Station station = hibernateSession.find(Station.class, stationId);
            
            if (station == null) {
                httpSession.setAttribute("message", "❌ Station not found!");
                response.sendRedirect("FindChargers.jsp");
                return;
            }
            
            // 7. Check Wallet Balance
            Double walletBalance = user.getWalletBalance();
            if (walletBalance == null) {
                walletBalance = 0.0;
            }
            
            if (walletBalance < amount) {
                httpSession.setAttribute("message", 
                    "❌ Insufficient wallet balance! Need ₹" + amount + 
                    " but have ₹" + String.format("%.2f", walletBalance));
                tx.rollback();
                response.sendRedirect("Booking.jsp?stationId=" + stationId);
                return;
            }
            
            // 8. Deduct from Wallet
            user.setWalletBalance(walletBalance - amount);
            
            // 9. Add Reward Points (10 points per ₹50)
            int pointsToAdd = (int) (amount / 5);
            int currentPoints = user.getPoints() != null ? user.getPoints() : 0;
            user.setPoints(currentPoints + pointsToAdd);
            
            // 10. Create Booking
            Booking booking = new Booking();
            booking.setUser(user);
            booking.setStation(station);
            booking.setAmount(amount);
            booking.setBookingDate(bookingDate);
            booking.setBookingTime(bookingTime); // Store as string "14:30"
            booking.setVehicleModel(vehicleModel);
            booking.setVehicleNumber(vehicleNumber);
            booking.setBatteryCapacity(batteryCapacity);
            booking.setStatus("Pending"); // Wait for owner approval
            booking.setCreatedAt(new Date());
            
            // 11. Save to Database
            hibernateSession.persist(booking);
            hibernateSession.merge(user); // Update wallet and points
            
            // 12. Commit Transaction
            tx.commit();
            
            System.out.println("✅ Booking created successfully! ID: " + booking.getBookingId());
            
//            // 13. Send Email (Async)
            final int bookingId = booking.getBookingId();
            final String stationName = station.getStationName();
            final String formattedDate = new SimpleDateFormat("MMM dd, yyyy").format(bookingDate);
//            
//            new Thread(() -> {
//                try {
//                    EmailSender.sendBookingConfirmation(
//                        user.getUserEmail(), 
//                        user.getUserName(), 
//                        stationName, 
//                        formattedDate + " at " + bookingTime, 
//                        amount
//                    );
//                    System.out.println("✉️ Email sent to: " + user.getUserEmail());
//                } catch (Exception e) {
//                    System.err.println("❌ Email failed: " + e.getMessage());
//                }
//            }).start();
            
            // 14. Success Message
            httpSession.setAttribute("message", 
                "✅ Booking Confirmed! " +
                "Booking ID: #" + bookingId + 
                " | Station: " + stationName + 
                " | Date: " + formattedDate + 
                " | Time: " + bookingTime +
                " | Paid: ₹" + String.format("%.2f", amount) + 
                " | Points: +" + pointsToAdd);
            
            response.sendRedirect("Dashboard.jsp");
            
        } catch (ParseException e) {
            if (tx != null && tx.isActive()) tx.rollback();
            httpSession.setAttribute("message", "❌ Invalid date format!");
            response.sendRedirect("FindChargers.jsp");
            e.printStackTrace();
            
        } catch (NumberFormatException e) {
            if (tx != null && tx.isActive()) tx.rollback();
            httpSession.setAttribute("message", "❌ Invalid number format!");
            response.sendRedirect("FindChargers.jsp");
            e.printStackTrace();
            
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            httpSession.setAttribute("message", "❌ Booking failed: " + e.getMessage());
            response.sendRedirect("FindChargers.jsp");
            e.printStackTrace();
            
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}