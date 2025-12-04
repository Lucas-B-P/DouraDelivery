package com.douradelivery.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserType userType;
    
    // Campos para registro completo
    @Column(unique = true)
    private String cpf;
    
    @Column(name = "birth_date")
    private LocalDate birthDate;
    
    private String phone;
    
    // Campos específicos para entregadores
    @Column(name = "cnh_number")
    private String cnhNumber;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "cnh_category")
    private CnhCategory cnhCategory;
    
    @Column(name = "cnh_expiry_date")
    private LocalDate cnhExpiryDate;
    
    // Caminhos dos arquivos de documentos
    @Column(name = "profile_photo_path")
    private String profilePhotoPath;
    
    @Column(name = "cpf_photo_path")
    private String cpfPhotoPath;
    
    @Column(name = "cnh_photo_path")
    private String cnhPhotoPath;
    
    // Status de verificação
    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status")
    private VerificationStatus verificationStatus = VerificationStatus.PENDING;
    
    @Builder.Default
    @Column(nullable = false)
    private Boolean active = true;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum UserType {
        CLIENT, DRIVER, ADMIN
    }
    
    public enum CnhCategory {
        A, B, C, D, E, AB, AC, AD, AE
    }
    
    public enum VerificationStatus {
        PENDING, APPROVED, REJECTED
    }
}