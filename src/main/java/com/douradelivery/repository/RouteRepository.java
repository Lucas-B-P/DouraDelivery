package com.douradelivery.repository;

import com.douradelivery.model.Route;
import com.douradelivery.model.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    List<Route> findByDriver(Driver driver);
    List<Route> findByStatus(Route.RouteStatus status);
    List<Route> findByDriverId(Long driverId);
}

