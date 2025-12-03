package com.douradelivery.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/entregador")
public class EntregadorController {
    
    @GetMapping("/orders")
    public ResponseEntity<Map<String, Object>> getAvailableOrders() {
        Map<String, Object> response = new HashMap<>();
        response.put("orders", new Object[0]);
        response.put("total", 0);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/orders/{orderId}/accept")
    public ResponseEntity<Map<String, Object>> acceptOrder(@PathVariable Long orderId) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Pedido aceito!");
        response.put("orderId", orderId);
        response.put("status", "ACCEPTED");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/telemetry")
    public ResponseEntity<Map<String, Object>> sendTelemetry(@RequestBody Map<String, Object> telemetryData) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Telemetria recebida!");
        response.put("status", "OK");
        return ResponseEntity.ok(response);
    }
}