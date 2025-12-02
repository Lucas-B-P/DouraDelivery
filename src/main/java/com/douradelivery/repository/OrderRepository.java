package com.douradelivery.repository;

import com.douradelivery.model.Order;
import com.douradelivery.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByClient(User client);
    List<Order> findByStatus(Order.OrderStatus status);
    List<Order> findByAssignedDriverId(Long driverId);
    List<Order> findByStatusIn(List<Order.OrderStatus> statuses);
}

