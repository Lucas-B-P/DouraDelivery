package com.douradelivery.controller;

import com.douradelivery.dto.DocumentUploadResponse;
import com.douradelivery.model.User;
import com.douradelivery.repository.UserRepository;
import com.douradelivery.service.FileUploadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {
    
    @Autowired
    private FileUploadService fileUploadService;
    
    @Autowired
    private UserRepository userRepository;
    
    @PostMapping("/upload/{userId}/{documentType}")
    public ResponseEntity<DocumentUploadResponse> uploadDocument(
            @PathVariable Long userId,
            @PathVariable String documentType,
            @RequestParam("file") MultipartFile file) {
        
        // Validar tipo de documento
        if (!isValidDocumentType(documentType)) {
            DocumentUploadResponse response = new DocumentUploadResponse();
            response.setSuccess(false);
            response.setMessage("Tipo de documento inválido. Use: profile, cpf ou cnh");
            return ResponseEntity.badRequest().body(response);
        }
        
        // Verificar se usuário existe
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            DocumentUploadResponse response = new DocumentUploadResponse();
            response.setSuccess(false);
            response.setMessage("Usuário não encontrado");
            return ResponseEntity.notFound().build();
        }
        
        // Upload do arquivo
        DocumentUploadResponse response = fileUploadService.uploadDocument(file, documentType, userId);
        
        if (response.isSuccess()) {
            // Atualizar caminho do documento no usuário
            User user = userOpt.get();
            updateUserDocumentPath(user, documentType, response.getFilePath());
            userRepository.save(user);
            
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @GetMapping("/download/{userId}/{documentType}/{fileName}")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Long userId,
            @PathVariable String documentType,
            @PathVariable String fileName) {
        
        try {
            Path filePath = Paths.get("uploads", "users", userId.toString(), documentType, fileName);
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_OCTET_STREAM)
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/status/{userId}")
    public ResponseEntity<Map<String, Object>> getDocumentStatus(@PathVariable Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        User user = userOpt.get();
        Map<String, Object> status = new HashMap<>();
        
        status.put("userId", userId);
        status.put("verificationStatus", user.getVerificationStatus().name());
        status.put("hasProfilePhoto", user.getProfilePhotoPath() != null);
        status.put("hasCpfPhoto", user.getCpfPhotoPath() != null);
        
        // Para entregadores, verificar CNH
        if (user.getUserType() == User.UserType.DRIVER) {
            status.put("hasCnhPhoto", user.getCnhPhotoPath() != null);
            status.put("cnhRequired", true);
        } else {
            status.put("hasCnhPhoto", false);
            status.put("cnhRequired", false);
        }
        
        // Calcular progresso
        int totalRequired = user.getUserType() == User.UserType.DRIVER ? 3 : 2;
        int completed = 0;
        if (user.getProfilePhotoPath() != null) completed++;
        if (user.getCpfPhotoPath() != null) completed++;
        if (user.getUserType() == User.UserType.DRIVER && user.getCnhPhotoPath() != null) completed++;
        
        status.put("completionPercentage", (completed * 100) / totalRequired);
        status.put("isComplete", completed == totalRequired);
        
        return ResponseEntity.ok(status);
    }
    
    private boolean isValidDocumentType(String documentType) {
        return "profile".equals(documentType) || 
               "cpf".equals(documentType) || 
               "cnh".equals(documentType);
    }
    
    private void updateUserDocumentPath(User user, String documentType, String filePath) {
        switch (documentType) {
            case "profile":
                user.setProfilePhotoPath(filePath);
                break;
            case "cpf":
                user.setCpfPhotoPath(filePath);
                break;
            case "cnh":
                user.setCnhPhotoPath(filePath);
                break;
        }
    }
}
