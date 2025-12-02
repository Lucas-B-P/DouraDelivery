package com.douradelivery.controller;

import com.douradelivery.dto.RouteResponse;
import com.douradelivery.model.Driver;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import com.douradelivery.model.User;
import com.douradelivery.repository.DriverRepository;
import com.douradelivery.repository.OrderRepository;
import com.douradelivery.repository.RouteRepository;
import com.douradelivery.repository.UserRepository;
import com.douradelivery.service.RoutingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {
    
    private final OrderRepository orderRepository;
    private final DriverRepository driverRepository;
    private final RouteRepository routeRepository;
    private final UserRepository userRepository;
    private final RoutingService routingService;
    
    /**
     * Admin visualiza todos os pedidos
     */
    @GetMapping("/pedidos")
    public ResponseEntity<List<Order>> todosPedidos() {
        List<Order> orders = orderRepository.findAll();
        return ResponseEntity.ok(orders);
    }
    
    /**
     * Admin visualiza todos os entregadores
     */
    @GetMapping("/entregadores")
    public ResponseEntity<List<Driver>> todosEntregadores() {
        List<Driver> drivers = driverRepository.findAll();
        return ResponseEntity.ok(drivers);
    }
    
    /**
     * Admin visualiza todas as rotas
     */
    @GetMapping("/rotas")
    public ResponseEntity<List<RouteResponse>> todasRotas() {
        List<Route> routes = routeRepository.findAll();
        List<RouteResponse> responses = routes.stream()
                .map(this::toRouteResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }
    
    /**
     * Admin força recálculo de rotas
     */
    @PostMapping("/rotas/recalcular")
    public ResponseEntity<Map<String, Object>> recalcularRotas() {
        Map<Long, List<Order>> routes = routingService.computeRoutes();
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Rotas recalculadas com sucesso");
        response.put("routesAssigned", routes.size());
        response.put("totalOrdersAssigned", routes.values().stream()
                .mapToInt(List::size)
                .sum());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Admin visualiza métricas do sistema
     */
    @GetMapping("/metricas")
    public ResponseEntity<Map<String, Object>> metricas() {
        Map<String, Object> metrics = new HashMap<>();
        
        long totalOrders = orderRepository.count();
        long newOrders = orderRepository.findByStatus(Order.OrderStatus.NEW).size();
        long assignedOrders = orderRepository.findByStatus(Order.OrderStatus.ASSIGNED).size();
        long deliveredOrders = orderRepository.findByStatus(Order.OrderStatus.DELIVERED).size();
        
        long totalDrivers = driverRepository.count();
        long availableDrivers = driverRepository.findByAvailableTrue().size();
        
        long activeRoutes = routeRepository.findByStatus(Route.RouteStatus.IN_PROGRESS).size();
        
        metrics.put("totalPedidos", totalOrders);
        metrics.put("pedidosNovos", newOrders);
        metrics.put("pedidosAtribuidos", assignedOrders);
        metrics.put("pedidosEntregues", deliveredOrders);
        metrics.put("totalEntregadores", totalDrivers);
        metrics.put("entregadoresDisponiveis", availableDrivers);
        metrics.put("rotasAtivas", activeRoutes);
        
        return ResponseEntity.ok(metrics);
    }
    
    /**
     * Admin cria um entregador
     */
    @PostMapping("/entregadores")
    public ResponseEntity<Driver> criarEntregador(@RequestBody Driver driver) {
        driver = driverRepository.save(driver);
        return ResponseEntity.ok(driver);
    }
    
    /**
     * Admin gerencia usuários
     */
    @GetMapping("/usuarios")
    public ResponseEntity<List<User>> todosUsuarios() {
        List<User> users = userRepository.findAll();
        return ResponseEntity.ok(users);
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

