package com.douradelivery.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TelemetryRequest {
    
    @NotNull(message = "Latitude é obrigatória")
    private Double lat;
    
    @NotNull(message = "Longitude é obrigatória")
    private Double lon;
    
    private Double speed;
    private Double heading;
    private Double accuracy;
}

