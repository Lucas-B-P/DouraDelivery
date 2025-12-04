package com.douradelivery.service;

import com.douradelivery.model.Document;
import com.douradelivery.model.Document.DocumentStatus;
import com.douradelivery.model.Document.DocumentType;
import com.douradelivery.model.User;
import com.douradelivery.repository.DocumentRepository;
import com.douradelivery.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DocumentService {
    
    private static final Logger logger = LoggerFactory.getLogger(DocumentService.class);
    
    @Autowired
    private DocumentRepository documentRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Value("${app.upload.dir:uploads}")
    private String uploadDir;
    
    public Map<String, Object> uploadDocuments(Long userId, Map<String, MultipartFile> files) {
        try {
            logger.info("Iniciando upload de documentos para usuário: {}", userId);
            
            Optional<User> userOpt = userRepository.findById(userId);
            if (!userOpt.isPresent()) {
                return createErrorResponse("Usuário não encontrado");
            }
            
            User user = userOpt.get();
            
            // Criar diretório de upload se não existir
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            List<Document> documents = new ArrayList<>();
            
            // Processar cada arquivo
            for (Map.Entry<String, MultipartFile> entry : files.entrySet()) {
                String fieldName = entry.getKey();
                MultipartFile file = entry.getValue();
                
                if (file != null && !file.isEmpty()) {
                    DocumentType documentType = mapFieldToDocumentType(fieldName);
                    if (documentType != null) {
                        Document document = saveFile(user, file, documentType);
                        if (document != null) {
                            documents.add(document);
                        }
                    }
                }
            }
            
            if (documents.isEmpty()) {
                return createErrorResponse("Nenhum documento válido foi enviado");
            }
            
            // Salvar documentos no banco
            documentRepository.saveAll(documents);
            
            logger.info("Upload concluído com sucesso. {} documentos salvos para usuário {}", 
                       documents.size(), userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Documentos enviados com sucesso!");
            response.put("documentsCount", documents.size());
            
            return response;
            
        } catch (Exception e) {
            logger.error("Erro ao fazer upload de documentos para usuário {}: {}", userId, e.getMessage(), e);
            return createErrorResponse("Erro interno do servidor: " + e.getMessage());
        }
    }
    
    private Document saveFile(User user, MultipartFile file, DocumentType documentType) {
        try {
            // Gerar nome único para o arquivo
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".jpg";
            
            String fileName = String.format("%s_%d_%d%s", 
                documentType.name().toLowerCase(),
                user.getId(),
                System.currentTimeMillis(),
                extension);
            
            // Salvar arquivo no sistema de arquivos
            Path filePath = Paths.get(uploadDir, fileName);
            Files.write(filePath, file.getBytes());
            
            // Criar registro no banco
            Document document = new Document(user, documentType, fileName, filePath.toString());
            
            logger.info("Arquivo salvo: {} para usuário {}", fileName, user.getId());
            
            return document;
            
        } catch (IOException e) {
            logger.error("Erro ao salvar arquivo para usuário {}: {}", user.getId(), e.getMessage(), e);
            return null;
        }
    }
    
    private DocumentType mapFieldToDocumentType(String fieldName) {
        switch (fieldName.toLowerCase()) {
            case "cpfdocument":
                return DocumentType.CPF;
            case "profilephoto":
                return DocumentType.PROFILE;
            case "cnhdocument":
                return DocumentType.CNH;
            case "vehicledocument":
                return DocumentType.VEHICLE;
            default:
                logger.warn("Tipo de documento não reconhecido: {}", fieldName);
                return null;
        }
    }
    
    public Map<String, Object> getDocumentStatus(Long userId) {
        try {
            logger.info("Buscando status dos documentos para usuário: {}", userId);
            
            Optional<User> userOpt = userRepository.findById(userId);
            if (!userOpt.isPresent()) {
                return createErrorResponse("Usuário não encontrado");
            }
            
            List<Document> documents = documentRepository.findByUserIdOrderBySubmittedAtDesc(userId);
            
            if (documents.isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("status", "NOT_SUBMITTED");
                response.put("message", "Nenhum documento enviado");
                return response;
            }
            
            // Pegar o documento mais recente para determinar o status geral
            Document latestDocument = documents.get(0);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("status", latestDocument.getStatus().name());
            response.put("observation", latestDocument.getObservation());
            response.put("submittedAt", latestDocument.getSubmittedAt());
            response.put("reviewedAt", latestDocument.getReviewedAt());
            
            // Adicionar lista de documentos
            List<Map<String, Object>> documentList = documents.stream()
                .map(this::documentToMap)
                .collect(Collectors.toList());
            response.put("documents", documentList);
            
            return response;
            
        } catch (Exception e) {
            logger.error("Erro ao buscar status dos documentos para usuário {}: {}", userId, e.getMessage(), e);
            return createErrorResponse("Erro interno do servidor");
        }
    }
    
    public List<Map<String, Object>> getPendingDocuments() {
        try {
            logger.info("Buscando documentos pendentes para análise");
            
            List<Document> pendingDocuments = documentRepository.findPendingDocumentsWithUser();
            
            // Agrupar por usuário
            Map<Long, List<Document>> documentsByUser = pendingDocuments.stream()
                .collect(Collectors.groupingBy(doc -> doc.getUser().getId()));
            
            List<Map<String, Object>> result = new ArrayList<>();
            
            for (Map.Entry<Long, List<Document>> entry : documentsByUser.entrySet()) {
                List<Document> userDocuments = entry.getValue();
                if (!userDocuments.isEmpty()) {
                    Document firstDoc = userDocuments.get(0);
                    User user = firstDoc.getUser();
                    
                    Map<String, Object> userDocumentMap = new HashMap<>();
                    userDocumentMap.put("userId", user.getId());
                    userDocumentMap.put("userName", user.getName());
                    userDocumentMap.put("userType", user.getUserType().name());
                    userDocumentMap.put("submittedAt", firstDoc.getSubmittedAt());
                    
                    List<Map<String, Object>> documents = userDocuments.stream()
                        .map(this::documentToMap)
                        .collect(Collectors.toList());
                    userDocumentMap.put("documents", documents);
                    
                    result.add(userDocumentMap);
                }
            }
            
            // Ordenar por data de submissão (mais antigos primeiro)
            result.sort((a, b) -> {
                LocalDateTime dateA = (LocalDateTime) a.get("submittedAt");
                LocalDateTime dateB = (LocalDateTime) b.get("submittedAt");
                return dateA.compareTo(dateB);
            });
            
            logger.info("Encontrados {} usuários com documentos pendentes", result.size());
            
            return result;
            
        } catch (Exception e) {
            logger.error("Erro ao buscar documentos pendentes: {}", e.getMessage(), e);
            return new ArrayList<>();
        }
    }
    
    public Map<String, Object> approveDocuments(Long userId, String observation, Long reviewerId) {
        return updateDocumentStatus(userId, DocumentStatus.APPROVED, observation, reviewerId);
    }
    
    public Map<String, Object> rejectDocuments(Long userId, String observation, Long reviewerId) {
        return updateDocumentStatus(userId, DocumentStatus.REJECTED, observation, reviewerId);
    }
    
    private Map<String, Object> updateDocumentStatus(Long userId, DocumentStatus status, 
                                                   String observation, Long reviewerId) {
        try {
            logger.info("Atualizando status dos documentos do usuário {} para {}", userId, status);
            
            Optional<User> userOpt = userRepository.findById(userId);
            if (!userOpt.isPresent()) {
                return createErrorResponse("Usuário não encontrado");
            }
            
            Optional<User> reviewerOpt = userRepository.findById(reviewerId);
            if (!reviewerOpt.isPresent()) {
                return createErrorResponse("Revisor não encontrado");
            }
            
            List<Document> userDocuments = documentRepository.findByUserIdAndStatus(userId, DocumentStatus.PENDING);
            
            if (userDocuments.isEmpty()) {
                return createErrorResponse("Nenhum documento pendente encontrado para este usuário");
            }
            
            // Atualizar todos os documentos pendentes do usuário
            LocalDateTime now = LocalDateTime.now();
            User reviewer = reviewerOpt.get();
            
            for (Document document : userDocuments) {
                document.setStatus(status);
                document.setObservation(observation);
                document.setReviewedAt(now);
                document.setReviewedBy(reviewer);
            }
            
            documentRepository.saveAll(userDocuments);
            
            logger.info("Status dos documentos do usuário {} atualizado para {} por revisor {}", 
                       userId, status, reviewerId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", String.format("Documentos %s com sucesso!", 
                status == DocumentStatus.APPROVED ? "aprovados" : "rejeitados"));
            response.put("status", status.name());
            response.put("documentsUpdated", userDocuments.size());
            
            return response;
            
        } catch (Exception e) {
            logger.error("Erro ao atualizar status dos documentos do usuário {}: {}", userId, e.getMessage(), e);
            return createErrorResponse("Erro interno do servidor");
        }
    }
    
    private Map<String, Object> documentToMap(Document document) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", document.getId());
        map.put("type", document.getDocumentType().name());
        map.put("fileName", document.getFileName());
        map.put("status", document.getStatus().name());
        map.put("submittedAt", document.getSubmittedAt());
        map.put("reviewedAt", document.getReviewedAt());
        map.put("observation", document.getObservation());
        return map;
    }
    
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return response;
    }
}
