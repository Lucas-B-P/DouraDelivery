package com.douradelivery.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false)
    private User client;
    
    @Column(nullable = false)
    private double originLat;
    
    @Column(nullable = false)
    private double originLon;
    
    @Column(nullable = false)
    private double destinationLat;
    
    @Column(nullable = false)
    private double destinationLon;
    
    private String originAddress;
    
    private String destinationAddress;
    
    @Column(nullable = false)
    private double weight;
    
    private double volume;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority = Priority.NORMAL;
    
    private LocalDateTime timeWindowStart;
    
    private LocalDateTime timeWindowEnd;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status = OrderStatus.NEW;
    
    @ManyToOne
    @JoinColumn(name = "driver_id")
    private Driver assignedDriver;
    
    @ManyToOne
    @JoinColumn(name = "route_id")
    private Route route;
    
    private String description;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    private LocalDateTime deliveredAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum Priority {
        LOW, NORMAL, HIGH, EXPRESS
    }
    
    public enum OrderStatus {
        NEW, ASSIGNED, PICKED, IN_TRANSIT, DELIVERED, CANCELED
    }
}

