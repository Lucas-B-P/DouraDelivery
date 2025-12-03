package com.douradelivery.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, Object> loginData) {
        Map<String, Object> response = new HashMap<>();
        response.put("token", "fake-jwt-token-for-testing");
        response.put("userType", "CLIENT");
        response.put("userId", 1);
        response.put("name", "Usuário Teste");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, Object> userData) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Usuário registrado com sucesso!");
        response.put("userId", 1);
        return ResponseEntity.ok(response);
    }
}