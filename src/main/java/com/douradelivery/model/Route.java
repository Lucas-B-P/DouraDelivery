package com.douradelivery.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "routes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Route {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "driver_id", nullable = false)
    private Driver driver;
    
    @OneToMany(mappedBy = "route", cascade = CascadeType.ALL)
    @OrderColumn(name = "sequence_order")
    @Builder.Default
    private List<Order> orders = new ArrayList<>();
    
    @Column(nullable = false)
    private double estimatedDistance; // em km
    
    @Column(nullable = false)
    private int estimatedDuration; // em segundos
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RouteStatus status = RouteStatus.PLANNED;
    
    private LocalDateTime startedAt;
    
    private LocalDateTime completedAt;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum RouteStatus {
        PLANNED, IN_PROGRESS, COMPLETED, CANCELED
    }
    
    public void addOrder(Order order) {
        if (!orders.contains(order)) {
            orders.add(order);
            order.setRoute(this);
        }
    }
    
    public void removeOrder(Order order) {
        orders.remove(order);
        order.setRoute(null);
    }
}

