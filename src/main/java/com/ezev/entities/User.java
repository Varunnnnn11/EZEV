package com.ezev.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(length = 10, name = "user_id")
    private Integer userId;

    @Column(length = 100, name = "user_name")
    private String userName;

    @Column(length = 100, name = "user_email")
    private String userEmail;

    @Column(length = 100, name = "user_password")
    private String userPassword;

    @Column(length = 12, name = "user_phone")
    private String userPhone;
    
    @Column(name = "user_type")
    private String userType;

    @Column(name = "user_points")
    private Integer points; 
    
    // --- THIS IS THE NEW FIELD YOU WERE MISSING ---
    @Column(name = "user_wallet")
    private Double walletBalance;

    public User() {
    }

    public User(String userName, String userEmail, String userPassword, String userPhone, String userType) {
        this.userName = userName;
        this.userEmail = userEmail;
        this.userPassword = userPassword;
        this.userPhone = userPhone;
        this.userType = userType;
        this.points = 50; 
        this.walletBalance = 0.0; // Default wallet is empty
    }

    // --- GETTERS AND SETTERS ---
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserPassword() { return userPassword; }
    public void setUserPassword(String userPassword) { this.userPassword = userPassword; }

    public String getUserPhone() { return userPhone; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }

    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }

    public Integer getPoints() { return points; }
    public void setPoints(Integer points) { this.points = points; }
    
    // --- VITAL: This is the method the error says is missing ---
    public Double getWalletBalance() { return walletBalance; }
    public void setWalletBalance(Double walletBalance) { this.walletBalance = walletBalance; }

    @Override
    public String toString() {
        return "User{" + "userId=" + userId + ", userName=" + userName + ", wallet=" + walletBalance + '}';
    }
}