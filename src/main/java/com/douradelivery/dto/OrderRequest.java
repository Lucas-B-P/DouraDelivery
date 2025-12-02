package com.douradelivery.dto;

import com.douradelivery.model.Order;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderRequest {
    
    @NotNull(message = "Latitude de origem é obrigatória")
    private Double originLat;
    
    @NotNull(message = "Longitude de origem é obrigatória")
    private Double originLon;
    
    @NotNull(message = "Latitude de destino é obrigatória")
    private Double destinationLat;
    
    @NotNull(message = "Longitude de destino é obrigatória")
    private Double destinationLon;
    
    private String originAddress;
    private String destinationAddress;
    
    @NotNull(message = "Peso é obrigatório")
    private Double weight;
    
    private Double volume;
    
    private Order.Priority priority = Order.Priority.NORMAL;
    
    private String description;
}

