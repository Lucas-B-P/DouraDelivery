-- Dados iniciais para testes (MySQL)

-- Usuário Admin
INSERT IGNORE INTO users (email, password, name, user_type, active, verification_status, created_at, updated_at)
VALUES ('admin@douradelivery.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'Administrador', 'ADMIN', true, 'APPROVED', NOW(), NOW());

-- Usuário Cliente de exemplo
INSERT IGNORE INTO users (email, password, name, user_type, cpf, phone, birth_date, active, verification_status, created_at, updated_at)
VALUES ('cliente@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'João Cliente', 'CLIENT', '12345678901', '11999999999', '1990-01-01', true, 'APPROVED', NOW(), NOW());

-- Usuário Entregador de exemplo (com CNH)
INSERT IGNORE INTO users (email, password, name, user_type, cpf, phone, birth_date, cnh_number, cnh_category, cnh_expiry_date, active, verification_status, created_at, updated_at)
VALUES ('entregador@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'Pedro Entregador', 'DRIVER', '98765432100', '11888888888', '1985-05-15', '12345678901', 'A', '2026-12-31', true, 'APPROVED', NOW(), NOW());


