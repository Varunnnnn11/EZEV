package com.ezev.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Station {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int stationId;
    
    private String stationName;      // e.g. "City Center Hub" or "Varun's Driveway"
    private String stationAddress;
    
    // --- NEW NAMING CONVENTION FOR FUTURE ---
    private String stationCategory;  // Values: "COMMERCIAL" or "RESIDENTIAL"
    private int ownerId;             // 0 if Commercial, UserID if Residential
    private String providerName;     // e.g. "Tata Power" or "Varun Kapoor"
    
    private String connectorType;    // e.g. "DC Fast", "Type 2 AC"
    
    @Column(length = 3000)
    private String stationDescription;
    
    private double latitude;
    private double longitude;
    private double pricePerUnit;
    private String status;           // "Active", "Busy", "Maintenance"
    private String stationImage;     // URL to image

    public Station() {
    }

    public Station(String stationName, String stationAddress, String stationCategory, int ownerId, String providerName, String connectorType, String stationDescription, double latitude, double longitude, double pricePerUnit, String status, String stationImage) {
        this.stationName = stationName;
        this.stationAddress = stationAddress;
        this.stationCategory = stationCategory;
        this.ownerId = ownerId;
        this.providerName = providerName;
        this.connectorType = connectorType;
        this.stationDescription = stationDescription;
        this.latitude = latitude;
        this.longitude = longitude;
        this.pricePerUnit = pricePerUnit;
        this.status = status;
        this.stationImage = stationImage;
    }

    // GETTERS AND SETTERS
    public int getStationId() { return stationId; }
    public void setStationId(int stationId) { this.stationId = stationId; }

    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }

    public String getStationAddress() { return stationAddress; }
    public void setStationAddress(String stationAddress) { this.stationAddress = stationAddress; }

    public String getStationCategory() { return stationCategory; }
    public void setStationCategory(String stationCategory) { this.stationCategory = stationCategory; }

    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }

    public String getProviderName() { return providerName; }
    public void setProviderName(String providerName) { this.providerName = providerName; }

    public String getConnectorType() { return connectorType; }
    public void setConnectorType(String connectorType) { this.connectorType = connectorType; }

    public String getStationDescription() { return stationDescription; }
    public void setStationDescription(String stationDescription) { this.stationDescription = stationDescription; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public double getPricePerUnit() { return pricePerUnit; }
    public void setPricePerUnit(double pricePerUnit) { this.pricePerUnit = pricePerUnit; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStationImage() { return stationImage; }
    public void setStationImage(String stationImage) { this.stationImage = stationImage; }
}