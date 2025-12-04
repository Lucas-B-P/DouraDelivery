package com.douradelivery.service;

import com.douradelivery.dto.DocumentUploadResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class FileUploadService {
    
    @Value("${app.upload.dir:uploads}")
    private String uploadDir;
    
    private final List<String> allowedExtensions = Arrays.asList("jpg", "jpeg", "png", "pdf");
    private final long maxFileSize = 5 * 1024 * 1024; // 5MB
    
    public DocumentUploadResponse uploadDocument(MultipartFile file, String documentType, Long userId) {
        DocumentUploadResponse response = new DocumentUploadResponse();
        
        try {
            // Validações
            if (file.isEmpty()) {
                response.setSuccess(false);
                response.setMessage("Arquivo não pode estar vazio");
                return response;
            }
            
            if (file.getSize() > maxFileSize) {
                response.setSuccess(false);
                response.setMessage("Arquivo muito grande. Máximo 5MB");
                return response;
            }
            
            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null) {
                response.setSuccess(false);
                response.setMessage("Nome do arquivo inválido");
                return response;
            }
            
            String extension = getFileExtension(originalFilename);
            if (!allowedExtensions.contains(extension.toLowerCase())) {
                response.setSuccess(false);
                response.setMessage("Tipo de arquivo não permitido. Use: " + String.join(", ", allowedExtensions));
                return response;
            }
            
            // Criar diretório se não existir
            Path uploadPath = Paths.get(uploadDir, "users", userId.toString(), documentType);
            Files.createDirectories(uploadPath);
            
            // Gerar nome único para o arquivo
            String fileName = UUID.randomUUID().toString() + "." + extension;
            Path filePath = uploadPath.resolve(fileName);
            
            // Salvar arquivo
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Preparar resposta
            response.setSuccess(true);
            response.setFileName(fileName);
            response.setFilePath(filePath.toString());
            response.setFileUrl("/api/files/download/" + userId + "/" + documentType + "/" + fileName);
            response.setFileSize(file.getSize());
            response.setMessage("Arquivo enviado com sucesso");
            
        } catch (IOException e) {
            response.setSuccess(false);
            response.setMessage("Erro ao salvar arquivo: " + e.getMessage());
        }
        
        return response;
    }
    
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex + 1);
        }
        return "";
    }
    
    public boolean deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            return Files.deleteIfExists(path);
        } catch (IOException e) {
            return false;
        }
    }
}
