package com.ezev.servlets;

import com.ezev.entities.User;
import com.ezev.helper.FactoryProvider;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. CATCH THE DATA (Using the 'name' from HTML)
            String name = request.getParameter("user_name");
            String email = request.getParameter("user_email");
            String pass = request.getParameter("user_password");
            String phone = request.getParameter("user_phone");
            String type = request.getParameter("user_type");

            // 2. CREATE A USER OBJECT
            User user = new User(name, email, pass, phone, type);

            // 3. OPEN THE DATABASE CONNECTION
            Session s = FactoryProvider.getFactory().openSession();
            Transaction tx = s.beginTransaction();
            
            // 4. SAVE TO DATABASE
            s.persist(user); 
            
            tx.commit();
            s.close();

            // 5. SEND SUCCESS MESSAGE TO LOGIN PAGE
            HttpSession httpSession = request.getSession();
            httpSession.setAttribute("message", "Registration Successful! Please Login.");
            
            // Redirect user to Login page
            response.sendRedirect("Login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}