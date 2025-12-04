package com.douradelivery.dto;

import com.douradelivery.model.User;
import lombok.Data;

import java.time.LocalDate;

@Data
public class RegisterRequest {
    private String name;
    private String email;
    private String password;
    private String userType; // CLIENT ou DRIVER
    
    // Campos obrigatórios para todos
    private String cpf;
    private LocalDate birthDate;
    private String phone;
    
    // Campos específicos para entregadores (obrigatórios se userType = DRIVER)
    private String cnhNumber;
    private String cnhCategory; // A, B, C, D, E, AB, AC, AD, AE
    private LocalDate cnhExpiryDate;
}
