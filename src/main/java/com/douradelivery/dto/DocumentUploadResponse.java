package com.douradelivery.dto;

import lombok.Data;

@Data
public class DocumentUploadResponse {
    private String fileName;
    private String filePath;
    private String fileUrl;
    private Long fileSize;
    private String message;
    private boolean success;
}
