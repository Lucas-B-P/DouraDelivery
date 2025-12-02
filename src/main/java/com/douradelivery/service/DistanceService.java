package com.douradelivery.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Serviço para calcular distâncias entre pontos.
 * Por padrão usa distância euclidiana (haversine para coordenadas geográficas).
 * Pode ser estendido para usar OSRM/GraphHopper para rotas reais.
 */
@Service
@Slf4j
public class DistanceService {
    
    @Value("${osrm.enabled:false}")
    private boolean osrmEnabled;
    
    @Value("${osrm.base-url:http://localhost:5000}")
    private String osrmBaseUrl;
    
    /**
     * Calcula distância em km usando fórmula de Haversine (considera curvatura da Terra)
     */
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        if (osrmEnabled) {
            return calculateDistanceWithOSRM(lat1, lon1, lat2, lon2);
        }
        
        return calculateHaversineDistance(lat1, lon1, lat2, lon2);
    }
    
    private double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Raio da Terra em km
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
    
    /**
     * Integração com OSRM para calcular distância real por estrada
     * TODO: Implementar chamada HTTP para OSRM
     */
    private double calculateDistanceWithOSRM(double lat1, double lon1, double lat2, double lon2) {
        // Exemplo de URL: http://localhost:5000/route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=false
        // Por enquanto, fallback para Haversine
        log.warn("OSRM habilitado mas não implementado. Usando Haversine como fallback.");
        return calculateHaversineDistance(lat1, lon1, lat2, lon2);
    }
    
    /**
     * Calcula tempo estimado em segundos baseado na distância
     * Assumindo velocidade média de 30 km/h em área urbana
     */
    public int estimateDuration(double distanceKm, double averageSpeedKmh) {
        return (int) ((distanceKm / averageSpeedKmh) * 3600);
    }
}

