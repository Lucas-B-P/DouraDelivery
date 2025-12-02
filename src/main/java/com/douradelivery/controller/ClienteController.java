package com.douradelivery.controller;

import com.douradelivery.dto.OrderRequest;
import com.douradelivery.model.Order;
import com.douradelivery.model.User;
import com.douradelivery.repository.OrderRepository;
import com.douradelivery.repository.UserRepository;
import com.douradelivery.service.RoutingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cliente")
@RequiredArgsConstructor
public class ClienteController {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final RoutingService routingService;
    
    /**
     * Cliente cria um novo pedido
     */
    @PostMapping("/pedidos")
    public ResponseEntity<Order> criarPedido(
            @Valid @RequestBody OrderRequest request,
            Authentication authentication) {
        
        String email = authentication.getName();
        User client = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        Order order = Order.builder()
                .client(client)
                .originLat(request.getOriginLat())
                .originLon(request.getOriginLon())
                .destinationLat(request.getDestinationLat())
                .destinationLon(request.getDestinationLon())
                .originAddress(request.getOriginAddress())
                .destinationAddress(request.getDestinationAddress())
                .weight(request.getWeight())
                .volume(request.getVolume() != null ? request.getVolume() : 0.0)
                .priority(request.getPriority() != null ? request.getPriority() : Order.Priority.NORMAL)
                .description(request.getDescription())
                .status(Order.OrderStatus.NEW)
                .build();
        
        order = orderRepository.save(order);
        
        // Dispara roteamento automático em background
        routingService.computeRoutes();
        
        return ResponseEntity.ok(order);
    }
    
    /**
     * Cliente visualiza seus pedidos
     */
    @GetMapping("/pedidos")
    public ResponseEntity<List<Order>> meusPedidos(Authentication authentication) {
        String email = authentication.getName();
        User client = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        List<Order> orders = orderRepository.findByClient(client);
        return ResponseEntity.ok(orders);
    }
    
    /**
     * Cliente visualiza detalhes de um pedido específico
     */
    @GetMapping("/pedidos/{id}")
    public ResponseEntity<Order> detalhesPedido(
            @PathVariable Long id,
            Authentication authentication) {
        
        String email = authentication.getName();
        User client = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
        
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado"));
        
        if (!order.getClient().getId().equals(client.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        return ResponseEntity.ok(order);
    }
}

