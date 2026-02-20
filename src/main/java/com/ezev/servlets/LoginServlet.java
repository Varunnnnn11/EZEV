package com.ezev.servlets;

import com.ezev.entities.User;
import com.ezev.helper.FactoryProvider;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.query.Query; // Make sure this import is here

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get email and password from form
        String email = request.getParameter("user_email");
        String pass = request.getParameter("user_password");

        // 2. Check Database
        Session s = FactoryProvider.getFactory().openSession();
        
        String q = "from User where userEmail=:e and userPassword=:p";
        
        // --- FIX IS HERE ---
        // We added ", User.class" to the end
        Query<User> query = s.createQuery(q, User.class);
        
        query.setParameter("e", email);
        query.setParameter("p", pass);

        User user = query.uniqueResult();
        s.close();

        // 3. Logic: Did we find a user?
        if (user == null) {
            // No user found -> Go back to Login with Error
            HttpSession session = request.getSession();
            session.setAttribute("message", "Invalid Email or Password! Try again.");
            response.sendRedirect("Login.jsp");
        } else {
            // LOGIN SUCCESS
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            // Redirect based on user type
            if (user.getUserType().equals("admin")) {
                response.sendRedirect("admin.jsp"); 
            } else {
                // CHANGED: Redirect to the new dashboard page
                response.sendRedirect("Dashboard.jsp"); 
            }
        }
    }
}