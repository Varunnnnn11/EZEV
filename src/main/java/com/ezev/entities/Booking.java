package com.ezev.entities;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "bookings")
public class Booking {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int bookingId;
    
    @Column(name = "booking_date")
    @Temporal(TemporalType.DATE)
    private Date bookingDate;
    
    @Column(name = "booking_time")
    private String bookingTime; // Stores time as "14:30" format
    
    @Column(name = "status")
    private String status; // "Confirmed", "Cancelled", "Completed"
    
    @Column(name = "amount")
    private double amount;
    
    // NEW FIELDS for vehicle details
    @Column(name = "vehicle_model")
    private String vehicleModel;
    
    @Column(name = "vehicle_number")
    private String vehicleNumber;
    
    @Column(name = "battery_capacity")
    private Double batteryCapacity;
    
    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    
    // RELATIONSHIPS
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    @ManyToOne
    @JoinColumn(name = "station_id")
    private Station station;
    
    // CONSTRUCTORS
    public Booking() {
        this.createdAt = new Date();
    }
    
    public Booking(User user, Station station, double amount) {
        this.user = user;
        this.station = station;
        this.amount = amount;
        this.bookingDate = new Date();
        this.createdAt = new Date();
        this.status = "Confirmed";
    }
    
    // GETTERS AND SETTERS
    public int getBookingId() { 
        return bookingId; 
    }
    
    public void setBookingId(int bookingId) { 
        this.bookingId = bookingId; 
    }
    
    public Date getBookingDate() { 
        return bookingDate; 
    }
    
    public void setBookingDate(Date bookingDate) { 
        this.bookingDate = bookingDate; 
    }
    
    public String getBookingTime() { 
        return bookingTime; 
    }
    
    public void setBookingTime(String bookingTime) { 
        this.bookingTime = bookingTime; 
    }
    
    public String getStatus() { 
        return status; 
    }
    
    public void setStatus(String status) { 
        this.status = status; 
    }
    
    public double getAmount() { 
        return amount; 
    }
    
    public void setAmount(double amount) { 
        this.amount = amount; 
    }
    
    public String getVehicleModel() { 
        return vehicleModel; 
    }
    
    public void setVehicleModel(String vehicleModel) { 
        this.vehicleModel = vehicleModel; 
    }
    
    public String getVehicleNumber() { 
        return vehicleNumber; 
    }
    
    public void setVehicleNumber(String vehicleNumber) { 
        this.vehicleNumber = vehicleNumber; 
    }
    
    public Double getBatteryCapacity() { 
        return batteryCapacity; 
    }
    
    public void setBatteryCapacity(Double batteryCapacity) { 
        this.batteryCapacity = batteryCapacity; 
    }
    
    public Date getCreatedAt() { 
        return createdAt; 
    }
    
    public void setCreatedAt(Date createdAt) { 
        this.createdAt = createdAt; 
    }
    
    public User getUser() { 
        return user; 
    }
    
    public void setUser(User user) { 
        this.user = user; 
    }
    
    public Station getStation() { 
        return station; 
    }
    
    public void setStation(Station station) { 
        this.station = station; 
    }
    
    @Override
    public String toString() {
        return "Booking{" +
                "bookingId=" + bookingId +
                ", bookingDate=" + bookingDate +
                ", bookingTime='" + bookingTime + '\'' +
                ", vehicleModel='" + vehicleModel + '\'' +
                ", amount=" + amount +
                ", status='" + status + '\'' +
                '}';
    }
}