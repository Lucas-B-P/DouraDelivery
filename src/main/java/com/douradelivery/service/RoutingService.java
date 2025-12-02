package com.douradelivery.service;

import com.douradelivery.model.Driver;
import com.douradelivery.model.Order;
import com.douradelivery.model.Route;
import com.douradelivery.repository.DriverRepository;
import com.douradelivery.repository.OrderRepository;
import com.douradelivery.repository.RouteRepository;
import com.douradelivery.service.DistanceService;
import com.douradelivery.service.NotificationIntegrationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class RoutingService {
    
    private final OrderRepository orderRepository;
    private final DriverRepository driverRepository;
    private final RouteRepository routeRepository;
    private final DistanceService distanceService;
    private final NotificationIntegrationService notificationService;
    
    /**
     * Algoritmo Greedy: atribui pedidos ao entregador mais próximo com capacidade disponível
     */
    @Transactional
    public Map<Long, List<Order>> computeRoutes() {
        List<Order> newOrders = orderRepository.findByStatus(Order.OrderStatus.NEW);
        List<Driver> availableDrivers = driverRepository.findByAvailableTrue();
        
        if (newOrders.isEmpty() || availableDrivers.isEmpty()) {
            log.info("Nenhum pedido novo ou entregador disponível");
            return new HashMap<>();
        }
        
        Map<Long, List<Order>> routes = new HashMap<>();
        for (Driver driver : availableDrivers) {
            routes.put(driver.getId(), new ArrayList<>());
        }
        
        // Ordena pedidos por prioridade (EXPRESS primeiro) e peso
        newOrders.sort((o1, o2) -> {
            int priorityCompare = o2.getPriority().compareTo(o1.getPriority());
            if (priorityCompare != 0) return priorityCompare;
            return Double.compare(o2.getWeight(), o1.getWeight());
        });
        
        for (Order order : newOrders) {
            Driver bestDriver = findBestDriver(order, availableDrivers, routes);
            
            if (bestDriver != null) {
                routes.get(bestDriver.getId()).add(order);
                order.setStatus(Order.OrderStatus.ASSIGNED);
                order.setAssignedDriver(bestDriver);
                order = orderRepository.save(order);
                log.info("Pedido {} atribuído ao entregador {}", order.getId(), bestDriver.getId());
                
                // Envia notificação
                notificationService.notifyOrderAssigned(bestDriver, order);
            } else {
                log.warn("Nenhum entregador disponível para o pedido {}", order.getId());
            }
        }
        
        // Cria ou atualiza rotas
        createOrUpdateRoutes(routes);
        
        return routes;
    }
    
    private Driver findBestDriver(Order order, List<Driver> drivers, Map<Long, List<Order>> routes) {
        Driver bestDriver = null;
        double bestScore = Double.MAX_VALUE;
        
        for (Driver driver : drivers) {
            List<Order> driverOrders = routes.get(driver.getId());
            double usedWeight = driverOrders.stream().mapToDouble(Order::getWeight).sum();
            double usedVolume = driverOrders.stream().mapToDouble(Order::getVolume).sum();
            
            // Verifica capacidade
            if (usedWeight + order.getWeight() > driver.getCapacityWeight() ||
                usedVolume + order.getVolume() > driver.getCapacityVolume()) {
                continue;
            }
            
            // Calcula distância do entregador até a origem do pedido
            double distance = distanceService.calculateDistance(
                driver.getCurrentLat(), driver.getCurrentLon(),
                order.getOriginLat(), order.getOriginLon()
            );
            
            // Score considera distância e prioridade
            double score = distance;
            if (order.getPriority() == Order.Priority.EXPRESS) {
                score *= 0.5; // Penaliza menos distância para pedidos expressos
            }
            
            if (score < bestScore) {
                bestScore = score;
                bestDriver = driver;
            }
        }
        
        return bestDriver;
    }
    
    private void createOrUpdateRoutes(Map<Long, List<Order>> routes) {
        for (Map.Entry<Long, List<Order>> entry : routes.entrySet()) {
            if (entry.getValue().isEmpty()) continue;
            
            Driver driver = driverRepository.findById(entry.getKey())
                    .orElseThrow(() -> new RuntimeException("Entregador não encontrado"));
            
            // Busca rota ativa ou cria nova
            Route route = routeRepository.findByDriverId(driver.getId()).stream()
                    .filter(r -> r.getStatus() == Route.RouteStatus.PLANNED ||
                                r.getStatus() == Route.RouteStatus.IN_PROGRESS)
                    .findFirst()
                    .orElse(Route.builder()
                            .driver(driver)
                            .status(Route.RouteStatus.PLANNED)
                            .build());
            
            // Adiciona novos pedidos à rota
            for (Order order : entry.getValue()) {
                if (!route.getOrders().contains(order)) {
                    route.addOrder(order);
                }
            }
            
            // Calcula distância e duração estimada
            calculateRouteMetrics(route);
            
            route = routeRepository.save(route);
            
            // Notifica entregador sobre atualização da rota
            notificationService.notifyRouteUpdated(driver, route);
        }
    }
    
    private void calculateRouteMetrics(Route route) {
        if (route.getOrders().isEmpty()) return;
        
        double totalDistance = 0;
        int totalDuration = 0;
        
        Driver driver = route.getDriver();
        double currentLat = driver.getCurrentLat();
        double currentLon = driver.getCurrentLon();
        
        for (Order order : route.getOrders()) {
            // Distância do ponto atual até a origem do pedido
            double distToOrigin = distanceService.calculateDistance(
                currentLat, currentLon,
                order.getOriginLat(), order.getOriginLon()
            );
            
            // Distância da origem até o destino
            double distToDestination = distanceService.calculateDistance(
                order.getOriginLat(), order.getOriginLon(),
                order.getDestinationLat(), order.getDestinationLon()
            );
            
            totalDistance += distToOrigin + distToDestination;
            
            // Estimativa de tempo (assumindo velocidade média de 30 km/h)
            totalDuration += (int) ((distToOrigin + distToDestination) / 30.0 * 3600);
            
            currentLat = order.getDestinationLat();
            currentLon = order.getDestinationLon();
        }
        
        route.setEstimatedDistance(totalDistance);
        route.setEstimatedDuration(totalDuration);
    }
    
    /**
     * Re-roteamento dinâmico quando há mudanças (novo pedido, mudança de trânsito, etc.)
     */
    @Transactional
    public void reoptimizeRoutes() {
        List<Order> unassignedOrders = orderRepository.findByStatus(Order.OrderStatus.NEW);
        List<Order> assignedOrders = orderRepository.findByStatus(Order.OrderStatus.ASSIGNED);
        
        // Re-otimiza apenas pedidos ainda não coletados
        List<Order> ordersToReoptimize = new ArrayList<>(unassignedOrders);
        ordersToReoptimize.addAll(assignedOrders);
        
        if (ordersToReoptimize.isEmpty()) {
            return;
        }
        
        computeRoutes();
    }
}

