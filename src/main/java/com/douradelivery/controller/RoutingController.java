package com.douradelivery.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/routing")
public class RoutingController {
    
    @PostMapping("/compute")
    public ResponseEntity<Map<String, Object>> computeRoutes() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Rotas calculadas!");
        response.put("routes", new Object[0]);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/routes")
    public ResponseEntity<Map<String, Object>> getRoutes() {
        Map<String, Object> response = new HashMap<>();
        response.put("routes", new Object[0]);
        response.put("total", 0);
        return ResponseEntity.ok(response);
    }
}