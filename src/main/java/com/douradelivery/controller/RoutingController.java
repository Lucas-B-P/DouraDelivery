package com.douradelivery.controller;

import com.douradelivery.dto.RouteResponse;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import com.douradelivery.repository.RouteRepository;
import com.douradelivery.service.RoutingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RoutingController {
    
    private final RoutingService routingService;
    private final RouteRepository routeRepository;
    
    /**
     * Endpoint público para forçar cálculo de rotas
     */
    @PostMapping("/compute")
    public ResponseEntity<Map<Long, List<Order>>> computeRoutes() {
        Map<Long, List<Order>> routes = routingService.computeRoutes();
        return ResponseEntity.ok(routes);
    }
    
    /**
     * Lista todas as rotas
     */
    @GetMapping
    public ResponseEntity<List<RouteResponse>> getAllRoutes() {
        List<Route> routes = routeRepository.findAll();
        List<RouteResponse> responses = routes.stream()
                .map(this::toRouteResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }
    
    private RouteResponse toRouteResponse(Route route) {
        return RouteResponse.builder()
                .routeId(route.getId())
                .driverId(route.getDriver().getId())
                .driverName(route.getDriver().getUser().getName())
                .orderIds(route.getOrders().stream()
                        .map(Order::getId)
                        .collect(Collectors.toList()))
                .estimatedDistance(route.getEstimatedDistance())
                .estimatedDuration(route.getEstimatedDuration())
                .status(route.getStatus())
                .build();
    }
}

