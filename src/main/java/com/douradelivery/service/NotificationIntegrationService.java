package com.douradelivery.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class NotificationIntegrationService {
    
    public void sendOrderNotification(Long driverId, Map<String, Object> orderData) {
        // Mock notification
        System.out.println("📱 Notificação enviada para entregador " + driverId + ": " + orderData);
    }
    
    public void sendStatusUpdate(Long clientId, String status, Map<String, Object> data) {
        // Mock status update
        System.out.println("📲 Status enviado para cliente " + clientId + ": " + status + " - " + data);
    }
    
    public Map<String, Object> getNotificationStatus(Long userId) {
        // Mock notification status
        Map<String, Object> status = new HashMap<>();
        status.put("userId", userId);
        status.put("connected", true);
        status.put("lastSeen", System.currentTimeMillis());
        return status;
    }
}