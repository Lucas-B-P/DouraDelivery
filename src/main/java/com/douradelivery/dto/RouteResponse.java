package com.douradelivery.dto;

import com.douradelivery.model.Route;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RouteResponse {
    private Long routeId;
    private Long driverId;
    private String driverName;
    private List<Long> orderIds;
    private double estimatedDistance;
    private int estimatedDuration;
    private Route.RouteStatus status;
}

