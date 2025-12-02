package com.douradelivery.repository;

import com.douradelivery.model.Telemetry;
import com.douradelivery.model.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TelemetryRepository extends JpaRepository<Telemetry, Long> {
    List<Telemetry> findByDriverOrderByTimestampDesc(Driver driver);
    List<Telemetry> findByDriverIdAndTimestampAfter(Long driverId, LocalDateTime timestamp);
    Telemetry findFirstByDriverIdOrderByTimestampDesc(Long driverId);
}

