package com.ezev.helper;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailSender {

    public static void sendBookingConfirmation(String toEmail, String userName, String stationName, String date, double amount) {
        
       final String fromEmail = ConfigReader.get("GMAIL_USER");
final String password = ConfigReader.get("GMAIL_PASSWORD"); 

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        // props.put("mail.debug", "true"); // Uncomment this line if you need to see error logs in console!

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Booking Confirmed: " + stationName);

            String content = "<h1>Booking Confirmation</h1>"
                    + "<p>Hi " + userName + ",</p>"
                    + "<p>Your charging slot at <b>" + stationName + "</b> has been successfully booked.</p>"
                    + "<p><b>Date:</b> " + date + "<br>"
                    + "<b>Amount Paid:</b> &#8377;" + amount + "</p>"
                    + "<p>Thank you for choosing EzEv!</p>";

           message.setContent(content, "text/html; charset=UTF-8");
            Transport.send(message);
            System.out.println("✅ Email sent successfully to " + toEmail);

        } catch (MessagingException e) {
            e.printStackTrace();
            System.err.println("❌ Email sending failed: " + e.getMessage());
        }
    }
}