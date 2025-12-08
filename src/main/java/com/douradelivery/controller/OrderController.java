package com.douradelivery.controller;

import com.douradelivery.model.Order;
import com.douradelivery.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OrderController {
    
    private final OrderService orderService;
    
    @PostMapping
    @PreAuthorize("hasRole('CLIENT') or hasRole('ADMIN')")
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {
        try {
            Order order = Order.builder()
                .originLat(request.getOriginLat())
                .originLon(request.getOriginLon())
                .destinationLat(request.getDestinationLat())
                .destinationLon(request.getDestinationLon())
                .originAddress(request.getOriginAddress())
                .destinationAddress(request.getDestinationAddress())
                .weight(request.getWeight())
                .volume(request.getVolume())
                .priority(request.getPriority() != null ? request.getPriority() : Order.Priority.NORMAL)
                .timeWindowStart(request.getTimeWindowStart())
                .timeWindowEnd(request.getTimeWindowEnd())
                .description(request.getDescription())
                .build();
            
            Order savedOrder = orderService.createOrder(order, request.getClientId());
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Pedido criado com sucesso!",
                "order", savedOrder
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao criar pedido: " + e.getMessage()
            ));
        }
    }
    
    @GetMapping("/client/{clientId}")
    @PreAuthorize("hasRole('CLIENT') or hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getOrdersByClient(@PathVariable Long clientId) {
        List<Order> orders = orderService.getOrdersByClient(clientId);
        return ResponseEntity.ok(orders);
    }
    
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getAllOrders() {
        List<Order> orders = orderService.getAllOrders();
        return ResponseEntity.ok(orders);
    }
    
    @GetMapping("/available")
    @PreAuthorize("hasRole('DRIVER') or hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getAvailableOrders() {
        List<Order> orders = orderService.getAvailableOrders();
        return ResponseEntity.ok(orders);
    }
    
    @GetMapping("/driver/{driverId}")
    @PreAuthorize("hasRole('DRIVER') or hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getOrdersByDriver(@PathVariable Long driverId) {
        List<Order> orders = orderService.getOrdersByDriver(driverId);
        return ResponseEntity.ok(orders);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        return orderService.getOrderById(id)
            .map(order -> ResponseEntity.ok(order))
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('DRIVER') or hasRole('ADMIN')")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> request) {
        try {
            Order.OrderStatus status = Order.OrderStatus.valueOf(request.get("status"));
            Order updatedOrder = orderService.updateOrderStatus(id, status);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Status do pedido atualizado com sucesso!",
                "order", updatedOrder
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao atualizar status: " + e.getMessage()
            ));
        }
    }
    
    @PutMapping("/{id}/assign/{driverId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> assignDriverToOrder(
            @PathVariable Long id, 
            @PathVariable Long driverId) {
        try {
            Order updatedOrder = orderService.assignDriverToOrder(id, driverId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Entregador atribuído ao pedido com sucesso!",
                "order", updatedOrder
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao atribuir entregador: " + e.getMessage()
            ));
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteOrder(@PathVariable Long id) {
        try {
            orderService.deleteOrder(id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Pedido excluído com sucesso!"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Erro ao excluir pedido: " + e.getMessage()
            ));
        }
    }
    
    @GetMapping("/{id}/distance")
    public ResponseEntity<?> getOrderDistance(@PathVariable Long id) {
        return orderService.getOrderById(id)
            .map(order -> {
                double distance = orderService.calculateOrderDistance(order);
                return ResponseEntity.ok(Map.of(
                    "orderId", id,
                    "distance", distance,
                    "unit", "km"
                ));
            })
            .orElse(ResponseEntity.notFound().build());
    }
    
    // DTO para criação de pedidos
    public static class CreateOrderRequest {
        private Long clientId;
        private double originLat;
        private double originLon;
        private double destinationLat;
        private double destinationLon;
        private String originAddress;
        private String destinationAddress;
        private double weight;
        private double volume;
        private Order.Priority priority;
        private java.time.LocalDateTime timeWindowStart;
        private java.time.LocalDateTime timeWindowEnd;
        private String description;
        
        // Getters and Setters
        public Long getClientId() { return clientId; }
        public void setClientId(Long clientId) { this.clientId = clientId; }
        
        public double getOriginLat() { return originLat; }
        public void setOriginLat(double originLat) { this.originLat = originLat; }
        
        public double getOriginLon() { return originLon; }
        public void setOriginLon(double originLon) { this.originLon = originLon; }
        
        public double getDestinationLat() { return destinationLat; }
        public void setDestinationLat(double destinationLat) { this.destinationLat = destinationLat; }
        
        public double getDestinationLon() { return destinationLon; }
        public void setDestinationLon(double destinationLon) { this.destinationLon = destinationLon; }
        
        public String getOriginAddress() { return originAddress; }
        public void setOriginAddress(String originAddress) { this.originAddress = originAddress; }
        
        public String getDestinationAddress() { return destinationAddress; }
        public void setDestinationAddress(String destinationAddress) { this.destinationAddress = destinationAddress; }
        
        public double getWeight() { return weight; }
        public void setWeight(double weight) { this.weight = weight; }
        
        public double getVolume() { return volume; }
        public void setVolume(double volume) { this.volume = volume; }
        
        public Order.Priority getPriority() { return priority; }
        public void setPriority(Order.Priority priority) { this.priority = priority; }
        
        public java.time.LocalDateTime getTimeWindowStart() { return timeWindowStart; }
        public void setTimeWindowStart(java.time.LocalDateTime timeWindowStart) { this.timeWindowStart = timeWindowStart; }
        
        public java.time.LocalDateTime getTimeWindowEnd() { return timeWindowEnd; }
        public void setTimeWindowEnd(java.time.LocalDateTime timeWindowEnd) { this.timeWindowEnd = timeWindowEnd; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
    }
}
