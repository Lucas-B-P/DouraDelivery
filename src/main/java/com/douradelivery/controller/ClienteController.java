package com.douradelivery.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/cliente")
public class ClienteController {
    
    @PostMapping("/orders")
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody Map<String, Object> orderData) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Pedido criado com sucesso!");
        response.put("orderId", 1);
        response.put("status", "CREATED");
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/orders")
    public ResponseEntity<Map<String, Object>> getOrders() {
        Map<String, Object> response = new HashMap<>();
        response.put("orders", new Object[0]);
        response.put("total", 0);
        return ResponseEntity.ok(response);
    }
}