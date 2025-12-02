package com.douradelivery.repository;

import com.douradelivery.model.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverRepository extends JpaRepository<Driver, Long> {
    List<Driver> findByAvailableTrue();
    Optional<Driver> findByUserId(Long userId);
    List<Driver> findByVehicleType(Driver.VehicleType vehicleType);
}

