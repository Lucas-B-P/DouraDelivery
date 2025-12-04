package com.douradelivery.repository;

import com.douradelivery.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    Optional<User> findByEmailAndActiveTrue(String email);
    
    boolean existsByEmail(String email);
    
    boolean existsByCpf(String cpf);
    
    List<User> findByUserTypeAndActiveTrue(User.UserType userType);
    
    List<User> findByVerificationStatus(User.VerificationStatus status);
    
    Optional<User> findByCpf(String cpf);
    
    Optional<User> findByCnhNumber(String cnhNumber);
}