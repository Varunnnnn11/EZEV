package com.ezev.servlets;

import com.ezev.entities.Booking;
import com.ezev.entities.User;
import com.ezev.helper.EmailSender;
import com.ezev.helper.FactoryProvider;
import java.io.IOException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "HandleRequestServlet", urlPatterns = {"/HandleRequestServlet"})
public class HandleRequestServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. Get Parameters
        String bookingIdStr = request.getParameter("id");
        String action = request.getParameter("action"); // "accept" or "decline"

        if(bookingIdStr == null || action == null) {
            response.sendRedirect("OwnerDashboard.jsp");
            return;
        }

        int bookingId = Integer.parseInt(bookingIdStr);
        Session s = FactoryProvider.getFactory().openSession();
        Transaction tx = s.beginTransaction();

        try {
            // 2. Fetch Booking
            Booking booking = s.find(Booking.class, bookingId);
            User customer = booking.getUser(); // The person who booked

            if ("accept".equalsIgnoreCase(action)) {
                // --- ACCEPT LOGIC ---
                booking.setStatus("Confirmed");
                s.merge(booking);
                
                // Prepare Email Data
                final String email = customer.getUserEmail();
                final String name = customer.getUserName();
                final String station = booking.getStation().getStationName();
                final String time = booking.getBookingTime();
                final String date = new SimpleDateFormat("MMM dd, yyyy").format(booking.getBookingDate());
                final double amount = booking.getAmount();

                // Send Email in Background Thread (Don't make user wait)
                new Thread(() -> {
                    EmailSender.sendBookingConfirmation(email, name, station, date + " at " + time, amount);
                }).start();

                request.getSession().setAttribute("message", "✅ Request Accepted! Confirmation email sent.");

            } else if ("decline".equalsIgnoreCase(action)) {
                // --- DECLINE LOGIC ---
                booking.setStatus("Declined");
                
                // REFUND: Give money back to customer
                double refundAmount = booking.getAmount();
                double currentBalance = customer.getWalletBalance();
                customer.setWalletBalance(currentBalance + refundAmount);
                
                // DEDUCT POINTS (Since booking failed)
                int pointsToDeduct = (int)(refundAmount / 5);
                int currentPoints = customer.getPoints();
                customer.setPoints(Math.max(0, currentPoints - pointsToDeduct));

                s.merge(booking);
                s.merge(customer); // Update User Wallet in DB

                request.getSession().setAttribute("message", "🚫 Request Declined. ₹" + refundAmount + " refunded to customer.");
            }

            tx.commit();
            response.sendRedirect("OwnerDashboard.jsp");

        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            s.close();
        }
    }
}