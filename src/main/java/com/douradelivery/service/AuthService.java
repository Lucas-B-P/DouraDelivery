package com.douradelivery.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {
    
    public Map<String, Object> login(String email, String password) {
        // Mock login - sempre retorna sucesso para teste
        Map<String, Object> response = new HashMap<>();
        response.put("token", "fake-jwt-token-for-testing-" + System.currentTimeMillis());
        response.put("userType", "CLIENT");
        response.put("userId", 1L);
        response.put("name", "Usuário Teste");
        response.put("email", email);
        return response;
    }
    
    public Map<String, Object> register(String name, String email, String password, String userType) {
        // Mock register - sempre retorna sucesso para teste
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Usuário registrado com sucesso!");
        response.put("userId", 1L);
        response.put("name", name);
        response.put("email", email);
        response.put("userType", userType);
        return response;
    }
}