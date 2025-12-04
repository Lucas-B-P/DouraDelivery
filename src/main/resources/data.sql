-- Dados iniciais para testes (MySQL)

-- Usuário Admin
INSERT IGNORE INTO users (email, password, name, user_type, active, created_at, updated_at)
VALUES ('admin@douradelivery.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'Administrador', 'ADMIN', true, NOW(), NOW());

-- Usuário Cliente de exemplo
INSERT IGNORE INTO users (email, password, name, user_type, active, created_at, updated_at)
VALUES ('cliente@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'João Cliente', 'CLIENTE', true, NOW(), NOW());

-- Usuário Entregador de exemplo
INSERT IGNORE INTO users (email, password, name, user_type, active, created_at, updated_at)
VALUES ('entregador@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJZO', 'Pedro Entregador', 'ENTREGADOR', true, NOW(), NOW());


