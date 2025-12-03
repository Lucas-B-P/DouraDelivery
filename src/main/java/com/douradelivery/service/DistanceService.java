package com.douradelivery.service;

import org.springframework.stereotype.Service;

@Service
public class DistanceService {
    
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // Fórmula de Haversine simplificada para teste
        double dx = lat1 - lat2;
        double dy = lon1 - lon2;
        return Math.sqrt(dx * dx + dy * dy) * 111.0; // Aproximação em km
    }
    
    public double calculateDuration(double lat1, double lon1, double lat2, double lon2) {
        // Mock duration - baseado na distância
        double distance = calculateDistance(lat1, lon1, lat2, lon2);
        return distance * 2; // 2 minutos por km (mock)
    }
}