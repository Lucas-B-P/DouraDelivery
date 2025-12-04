package com.douradelivery.controller;

import com.douradelivery.service.DocumentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class DocumentController {
    
    private static final Logger logger = LoggerFactory.getLogger(DocumentController.class);
    
    @Autowired
    private DocumentService documentService;
    
    @PostMapping("/documents/upload")
    public ResponseEntity<Map<String, Object>> uploadDocuments(
            @RequestParam("userId") Long userId,
            @RequestParam(value = "cpfDocument", required = false) MultipartFile cpfDocument,
            @RequestParam(value = "profilePhoto", required = false) MultipartFile profilePhoto,
            @RequestParam(value = "cnhDocument", required = false) MultipartFile cnhDocument,
            @RequestParam(value = "vehicleDocument", required = false) MultipartFile vehicleDocument) {
        
        try {
            logger.info("Recebida solicitação de upload de documentos para usuário: {}", userId);
            
            // Validar parâmetros obrigatórios
            if (userId == null) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "ID do usuário é obrigatório");
                return ResponseEntity.badRequest().body(errorResponse);
            }
            
            // Validar se pelo menos um documento foi enviado
            if ((cpfDocument == null || cpfDocument.isEmpty()) && 
                (profilePhoto == null || profilePhoto.isEmpty()) &&
                (cnhDocument == null || cnhDocument.isEmpty()) &&
                (vehicleDocument == null || vehicleDocument.isEmpty())) {
                
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("message", "Pelo menos um documento deve ser enviado");
                return ResponseEntity.badRequest().body(errorResponse);
            }
            
            // Preparar mapa de arquivos
            Map<String, MultipartFile> files = new HashMap<>();
            if (cpfDocument != null && !cpfDocument.isEmpty()) {
                files.put("cpfDocument", cpfDocument);
            }
            if (profilePhoto != null && !profilePhoto.isEmpty()) {
                files.put("profilePhoto", profilePhoto);
            }
            if (cnhDocument != null && !cnhDocument.isEmpty()) {
                files.put("cnhDocument", cnhDocument);
            }
            if (vehicleDocument != null && !vehicleDocument.isEmpty()) {
                files.put("vehicleDocument", vehicleDocument);
            }
            
            // Processar upload
            Map<String, Object> result = documentService.uploadDocuments(userId, files);
            
            if ((Boolean) result.get("success")) {
                logger.info("Upload de documentos concluído com sucesso para usuário: {}", userId);
                return ResponseEntity.ok(result);
            } else {
                logger.warn("Falha no upload de documentos para usuário {}: {}", userId, result.get("message"));
                return ResponseEntity.badRequest().body(result);
            }
            
        } catch (Exception e) {
            logger.error("Erro inesperado no upload de documentos para usuário {}: {}", userId, e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Erro interno do servidor");
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    @GetMapping("/documents/status/{userId}")
    public ResponseEntity<Map<String, Object>> getDocumentStatus(@PathVariable Long userId) {
        try {
            logger.info("Buscando status dos documentos para usuário: {}", userId);
            
            Map<String, Object> result = documentService.getDocumentStatus(userId);
            
            if ((Boolean) result.get("success")) {
                return ResponseEntity.ok(result);
            } else {
                return ResponseEntity.badRequest().body(result);
            }
            
        } catch (Exception e) {
            logger.error("Erro ao buscar status dos documentos para usuário {}: {}", userId, e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Erro interno do servidor");
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    @GetMapping("/admin/documents/pending")
    public ResponseEntity<List<Map<String, Object>>> getPendingDocuments() {
        try {
            logger.info("Buscando documentos pendentes para análise");
            
            List<Map<String, Object>> result = documentService.getPendingDocuments();
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            logger.error("Erro ao buscar documentos pendentes: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().body(List.of());
        }
    }
    
    @PostMapping("/admin/documents/approve")
    public ResponseEntity<Map<String, Object>> approveDocuments(
            @RequestBody Map<String, Object> request) {
        
        try {
            Long userId = Long.valueOf(request.get("userId").toString());
            String observation = (String) request.get("observation");
            Long reviewerId = 1L; // TODO: Pegar do JWT/sessão
            
            logger.info("Aprovando documentos do usuário {} por revisor {}", userId, reviewerId);
            
            Map<String, Object> result = documentService.approveDocuments(userId, observation, reviewerId);
            
            if ((Boolean) result.get("success")) {
                return ResponseEntity.ok(result);
            } else {
                return ResponseEntity.badRequest().body(result);
            }
            
        } catch (Exception e) {
            logger.error("Erro ao aprovar documentos: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Erro interno do servidor");
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    @PostMapping("/admin/documents/reject")
    public ResponseEntity<Map<String, Object>> rejectDocuments(
            @RequestBody Map<String, Object> request) {
        
        try {
            Long userId = Long.valueOf(request.get("userId").toString());
            String observation = (String) request.get("observation");
            Long reviewerId = 1L; // TODO: Pegar do JWT/sessão
            
            logger.info("Rejeitando documentos do usuário {} por revisor {}", userId, reviewerId);
            
            Map<String, Object> result = documentService.rejectDocuments(userId, observation, reviewerId);
            
            if ((Boolean) result.get("success")) {
                return ResponseEntity.ok(result);
            } else {
                return ResponseEntity.badRequest().body(result);
            }
            
        } catch (Exception e) {
            logger.error("Erro ao rejeitar documentos: {}", e.getMessage(), e);
            
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "Erro interno do servidor");
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
}