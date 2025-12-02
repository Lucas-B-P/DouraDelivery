package com.douradelivery.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "drivers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Driver {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;
    
    @Column(nullable = false)
    private double currentLat;
    
    @Column(nullable = false)
    private double currentLon;
    
    @Column(nullable = false)
    private double capacityWeight;
    
    @Column(nullable = false)
    private double capacityVolume;
    
    @Column(nullable = false)
    private boolean available = true;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private VehicleType vehicleType;
    
    private String phoneNumber;
    
    private String licensePlate;
    
    private LocalDateTime lastSeenAt;
    
    @OneToMany(mappedBy = "assignedDriver", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Order> assignedOrders = new ArrayList<>();
    
    @OneToMany(mappedBy = "driver", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Route> routes = new ArrayList<>();
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        lastSeenAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum VehicleType {
        MOTO, CARRO, VAN
    }
    
    public double getCurrentUsedWeight() {
        return assignedOrders.stream()
                .filter(o -> o.getStatus() != Order.OrderStatus.DELIVERED 
                          && o.getStatus() != Order.OrderStatus.CANCELED)
                .mapToDouble(Order::getWeight)
                .sum();
    }
    
    public double getCurrentUsedVolume() {
        return assignedOrders.stream()
                .filter(o -> o.getStatus() != Order.OrderStatus.DELIVERED 
                          && o.getStatus() != Order.OrderStatus.CANCELED)
                .mapToDouble(Order::getVolume)
                .sum();
    }
    
    public boolean hasCapacity(double weight, double volume) {
        return (getCurrentUsedWeight() + weight <= capacityWeight) &&
               (getCurrentUsedVolume() + volume <= capacityVolume);
    }
}

