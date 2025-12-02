package com.douradelivery.websocket;

import com.douradelivery.model.Driver;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Serviço para enviar notificações em tempo real via WebSocket
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    
    private final SimpMessagingTemplate messagingTemplate;
    
    /**
     * Notifica entregador sobre novo pedido atribuído
     */
    public void notifyDriverNewOrder(Driver driver, Order order) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "NEW_ORDER");
        payload.put("orderId", order.getId());
        payload.put("originLat", order.getOriginLat());
        payload.put("originLon", order.getOriginLon());
        payload.put("destinationLat", order.getDestinationLat());
        payload.put("destinationLon", order.getDestinationLon());
        payload.put("priority", order.getPriority());
        
        messagingTemplate.convertAndSend("/queue/driver/" + driver.getId(), payload);
        log.info("Notificação enviada ao entregador {} sobre pedido {}", driver.getId(), order.getId());
    }
    
    /**
     * Notifica entregador sobre rota atualizada
     */
    public void notifyDriverRouteUpdate(Driver driver, Route route) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "ROUTE_UPDATE");
        payload.put("routeId", route.getId());
        payload.put("estimatedDistance", route.getEstimatedDistance());
        payload.put("estimatedDuration", route.getEstimatedDuration());
        payload.put("orders", route.getOrders());
        
        messagingTemplate.convertAndSend("/queue/driver/" + driver.getId(), payload);
        log.info("Rota atualizada enviada ao entregador {}", driver.getId());
    }
    
    /**
     * Notifica cliente sobre atualização do pedido
     */
    public void notifyClientOrderUpdate(Long clientId, Order order) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "ORDER_UPDATE");
        payload.put("orderId", order.getId());
        payload.put("status", order.getStatus());
        if (order.getAssignedDriver() != null) {
            payload.put("driverName", order.getAssignedDriver().getUser().getName());
        }
        
        messagingTemplate.convertAndSend("/queue/client/" + clientId, payload);
        log.info("Atualização de pedido enviada ao cliente {}", clientId);
    }
    
    /**
     * Notifica admin sobre eventos do sistema
     */
    public void notifyAdmin(String eventType, Object data) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", eventType);
        payload.put("data", data);
        
        messagingTemplate.convertAndSend("/topic/admin", payload);
        log.info("Notificação admin: {}", eventType);
    }
}

