package com.douradelivery.service;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

@Service
public class DocumentValidationService {
    
    private static final Pattern CPF_PATTERN = Pattern.compile("\\d{11}");
    private static final Pattern PHONE_PATTERN = Pattern.compile("\\d{10,11}");
    private static final Pattern CNH_PATTERN = Pattern.compile("\\d{11}");
    
    public boolean isValidCPF(String cpf) {
        if (cpf == null || cpf.length() != 11 || !CPF_PATTERN.matcher(cpf).matches()) {
            return false;
        }
        
        // Verifica se todos os dígitos são iguais
        if (cpf.chars().distinct().count() == 1) {
            return false;
        }
        
        return isValidCPFChecksum(cpf);
    }
    
    private boolean isValidCPFChecksum(String cpf) {
        try {
            // Cálculo do primeiro dígito verificador
            int sum = 0;
            for (int i = 0; i < 9; i++) {
                sum += Character.getNumericValue(cpf.charAt(i)) * (10 - i);
            }
            int firstDigit = 11 - (sum % 11);
            if (firstDigit >= 10) firstDigit = 0;
            
            // Cálculo do segundo dígito verificador
            sum = 0;
            for (int i = 0; i < 10; i++) {
                sum += Character.getNumericValue(cpf.charAt(i)) * (11 - i);
            }
            int secondDigit = 11 - (sum % 11);
            if (secondDigit >= 10) secondDigit = 0;
            
            // Verificação
            return Character.getNumericValue(cpf.charAt(9)) == firstDigit &&
                   Character.getNumericValue(cpf.charAt(10)) == secondDigit;
        } catch (Exception e) {
            return false;
        }
    }
    
    public boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String cleanPhone = phone.replaceAll("[^\\d]", "");
        return PHONE_PATTERN.matcher(cleanPhone).matches();
    }
    
    public boolean isValidCNH(String cnh) {
        if (cnh == null || cnh.length() != 11 || !CNH_PATTERN.matcher(cnh).matches()) {
            return false;
        }
        
        // Verifica se todos os dígitos são iguais
        if (cnh.chars().distinct().count() == 1) {
            return false;
        }
        
        return true; // Simplificado - em produção implementar algoritmo completo da CNH
    }
    
    public boolean isValidBirthDate(LocalDate birthDate) {
        if (birthDate == null) return false;
        
        LocalDate now = LocalDate.now();
        LocalDate minAge = now.minusYears(18); // Idade mínima 18 anos
        LocalDate maxAge = now.minusYears(100); // Idade máxima 100 anos
        
        return !birthDate.isAfter(minAge) && !birthDate.isBefore(maxAge);
    }
    
    public boolean isValidCNHExpiryDate(LocalDate expiryDate) {
        if (expiryDate == null) return false;
        return expiryDate.isAfter(LocalDate.now());
    }
    
    public boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return Pattern.compile(emailRegex).matcher(email).matches();
    }
    
    public String cleanCPF(String cpf) {
        if (cpf == null) return null;
        return cpf.replaceAll("[^\\d]", "");
    }
    
    public String cleanPhone(String phone) {
        if (phone == null) return null;
        return phone.replaceAll("[^\\d]", "");
    }
    
    public String cleanCNH(String cnh) {
        if (cnh == null) return null;
        return cnh.replaceAll("[^\\d]", "");
    }
}
