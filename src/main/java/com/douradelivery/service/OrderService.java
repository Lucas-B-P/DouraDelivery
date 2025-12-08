package com.douradelivery.service;

import com.douradelivery.model.Order;
import com.douradelivery.model.User;
import com.douradelivery.repository.OrderRepository;
import com.douradelivery.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    
    public Order createOrder(Order order, Long clientId) {
        User client = userRepository.findById(clientId)
            .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        
        order.setClient(client);
        order.setStatus(Order.OrderStatus.NEW);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        
        return orderRepository.save(order);
    }
    
    public List<Order> getOrdersByClient(Long clientId) {
        User client = userRepository.findById(clientId)
            .orElseThrow(() -> new RuntimeException("Cliente não encontrado"));
        return orderRepository.findByClient(client);
    }
    
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
    
    public List<Order> getOrdersByStatus(Order.OrderStatus status) {
        return orderRepository.findByStatus(status);
    }
    
    public List<Order> getOrdersByDriver(Long driverId) {
        return orderRepository.findByAssignedDriverId(driverId);
    }
    
    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }
    
    public Order updateOrderStatus(Long orderId, Order.OrderStatus status) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        order.setStatus(status);
        order.setUpdatedAt(LocalDateTime.now());
        
        if (status == Order.OrderStatus.DELIVERED) {
            order.setDeliveredAt(LocalDateTime.now());
        }
        
        return orderRepository.save(order);
    }
    
    public Order assignDriverToOrder(Long orderId, Long driverId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        // Aqui você pode adicionar lógica para verificar se o driver existe
        // Driver driver = driverRepository.findById(driverId)...
        
        order.setStatus(Order.OrderStatus.ASSIGNED);
        order.setUpdatedAt(LocalDateTime.now());
        
        return orderRepository.save(order);
    }
    
    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }
    
    public List<Order> getAvailableOrders() {
        return orderRepository.findByStatus(Order.OrderStatus.NEW);
    }
    
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // Fórmula de Haversine para calcular distância entre dois pontos
        final int R = 6371; // Raio da Terra em km
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;
        
        return distance;
    }
    
    public double calculateOrderDistance(Order order) {
        return calculateDistance(
            order.getOriginLat(), 
            order.getOriginLon(), 
            order.getDestinationLat(), 
            order.getDestinationLon()
        );
    }
}
