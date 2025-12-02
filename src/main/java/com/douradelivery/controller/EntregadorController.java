package com.douradelivery.controller;

import com.douradelivery.dto.TelemetryRequest;
import com.douradelivery.model.Driver;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import com.douradelivery.model.Telemetry;
import com.douradelivery.repository.DriverRepository;
import com.douradelivery.repository.OrderRepository;
import com.douradelivery.repository.RouteRepository;
import com.douradelivery.repository.TelemetryRepository;
import com.douradelivery.repository.UserRepository;
import com.douradelivery.service.RoutingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/entregador")
@RequiredArgsConstructor
public class EntregadorController {
    
    private final DriverRepository driverRepository;
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final RouteRepository routeRepository;
    private final TelemetryRepository telemetryRepository;
    private final RoutingService routingService;
    
    /**
     * Entregador visualiza pedidos atribuídos a ele
     */
    @GetMapping("/pedidos")
    public ResponseEntity<List<Order>> meusPedidos(Authentication authentication) {
        Driver driver = getDriverFromAuth(authentication);
        List<Order> orders = orderRepository.findByAssignedDriverId(driver.getId());
        return ResponseEntity.ok(orders);
    }
    
    /**
     * Entregador aceita um pedido
     */
    @PostMapping("/pedidos/{id}/aceitar")
    public ResponseEntity<Order> aceitarPedido(
            @PathVariable Long id,
            Authentication authentication) {
        
        Driver driver = getDriverFromAuth(authentication);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        if (!order.getAssignedDriver().getId().equals(driver.getId())) {
            return ResponseEntity.badRequest().build();
        }
        
        if (order.getStatus() != Order.OrderStatus.ASSIGNED) {
            return ResponseEntity.badRequest().build();
        }
        
        order.setStatus(Order.OrderStatus.PICKED);
        order = orderRepository.save(order);
        
        // Atualiza status da rota se necessário
        if (order.getRoute() != null) {
            Route route = order.getRoute();
            if (route.getStatus() == Route.RouteStatus.PLANNED) {
                route.setStatus(Route.RouteStatus.IN_PROGRESS);
                route.setStartedAt(LocalDateTime.now());
                routeRepository.save(route);
            }
        }
        
        return ResponseEntity.ok(order);
    }
    
    /**
     * Entregador recusa um pedido
     */
    @PostMapping("/pedidos/{id}/recusar")
    public ResponseEntity<Void> recusarPedido(
            @PathVariable Long id,
            Authentication authentication) {
        
        Driver driver = getDriverFromAuth(authentication);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        if (!order.getAssignedDriver().getId().equals(driver.getId())) {
            return ResponseEntity.badRequest().build();
        }
        
        // Remove atribuição e volta para fila
        order.setStatus(Order.OrderStatus.NEW);
        order.setAssignedDriver(null);
        order.setRoute(null);
        orderRepository.save(order);
        
        // Re-otimiza rotas
        routingService.reoptimizeRoutes();
        
        return ResponseEntity.ok().build();
    }
    
    /**
     * Entregador envia sua localização (telemetria)
     */
    @PostMapping("/telemetria")
    public ResponseEntity<Telemetry> enviarTelemetria(
            @Valid @RequestBody TelemetryRequest request,
            Authentication authentication) {
        
        Driver driver = getDriverFromAuth(authentication);
        
        // Atualiza posição do entregador
        driver.setCurrentLat(request.getLat());
        driver.setCurrentLon(request.getLon());
        driver.setLastSeenAt(LocalDateTime.now());
        driverRepository.save(driver);
        
        // Salva telemetria
        Telemetry telemetry = Telemetry.builder()
                .driver(driver)
                .lat(request.getLat())
                .lon(request.getLon())
                .speed(request.getSpeed())
                .heading(request.getHeading())
                .accuracy(request.getAccuracy())
                .timestamp(LocalDateTime.now())
                .build();
        
        telemetry = telemetryRepository.save(telemetry);
        
        // Verifica se precisa re-rotear (ex: entregador muito longe do planejado)
        // TODO: Implementar lógica de re-roteamento baseada em telemetria
        
        return ResponseEntity.ok(telemetry);
    }
    
    /**
     * Entregador confirma entrega
     */
    @PostMapping("/pedidos/{id}/entregar")
    public ResponseEntity<Order> confirmarEntrega(
            @PathVariable Long id,
            Authentication authentication) {
        
        Driver driver = getDriverFromAuth(authentication);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        if (!order.getAssignedDriver().getId().equals(driver.getId())) {
            return ResponseEntity.badRequest().build();
        }
        
        order.setStatus(Order.OrderStatus.DELIVERED);
        order.setDeliveredAt(LocalDateTime.now());
        order = orderRepository.save(order);
        
        // Verifica se a rota foi completada
        if (order.getRoute() != null) {
            Route route = order.getRoute();
            boolean allDelivered = route.getOrders().stream()
                    .allMatch(o -> o.getStatus() == Order.OrderStatus.DELIVERED);
            
            if (allDelivered) {
                route.setStatus(Route.RouteStatus.COMPLETED);
                route.setCompletedAt(LocalDateTime.now());
                routeRepository.save(route);
            }
        }
        
        return ResponseEntity.ok(order);
    }
    
    /**
     * Entregador visualiza sua rota atual
     */
    @GetMapping("/rota")
    public ResponseEntity<Route> minhaRota(Authentication authentication) {
        Driver driver = getDriverFromAuth(authentication);
        List<Route> routes = routeRepository.findByDriverId(driver.getId());
        
        Route activeRoute = routes.stream()
                .filter(r -> r.getStatus() == Route.RouteStatus.PLANNED ||
                           r.getStatus() == Route.RouteStatus.IN_PROGRESS)
                .findFirst()
                .orElse(null);
        
        return ResponseEntity.ok(activeRoute);
    }
    
    private Driver getDriverFromAuth(Authentication authentication) {
        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        return driverRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Entregador não encontrado"));
    }
}

