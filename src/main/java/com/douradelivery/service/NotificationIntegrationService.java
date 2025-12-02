package com.douradelivery.service;

import com.douradelivery.model.Driver;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import com.douradelivery.websocket.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * Serviço que integra notificações com o sistema de roteamento
 */
@Service
@RequiredArgsConstructor
public class NotificationIntegrationService {
    
    private final NotificationService notificationService;
    
    public void notifyOrderAssigned(Driver driver, Order order) {
        notificationService.notifyDriverNewOrder(driver, order);
        notificationService.notifyClientOrderUpdate(order.getClient().getId(), order);
    }
    
    public void notifyRouteUpdated(Driver driver, Route route) {
        notificationService.notifyDriverRouteUpdate(driver, route);
    }
    
    public void notifyClientOrderUpdate(Long clientId, Order order) {
        notificationService.notifyClientOrderUpdate(clientId, order);
    }
}

