# DouraDelivery - Sistema de Roteamento Logístico

Sistema completo de roteamento automático em tempo real para entregas.

## 🚀 Tecnologias

- **Backend**: Java 17 + Spring Boot 3.2
- **Banco de Dados**: MySQL 8.0
- **Cache**: Redis (opcional)
- **Mensageria**: Kafka (opcional)
- **Frontend**: Flutter (Android)

## 📋 Funcionalidades

- ✅ Autenticação JWT (Cliente, Entregador, Admin)
- ✅ Criação de Pedidos com localização GPS
- ✅ Roteamento Automático (algoritmo greedy)
- ✅ Notificações em Tempo Real via WebSocket
- ✅ Telemetria GPS para rastreamento
- ✅ Re-roteamento Dinâmico
- ✅ Painel Administrativo
- ✅ API REST completa
- ✅ App Flutter Android

## 🏗️ Arquitetura

```
Backend (Spring Boot)
    ├── REST API
    ├── WebSocket (Notificações)
    ├── Serviço de Roteamento
    └── Integração com MySQL/Redis/Kafka

App Flutter
    ├── Autenticação JWT
    ├── CRUD de Pedidos
    ├── GPS Tracking
    └── Notificações em Tempo Real
```

## 🚀 Quick Start

### Backend

```bash
# 1. Configurar MySQL
# 2. Editar application.yml com credenciais
# 3. Executar
mvn spring-boot:run
```

### App Flutter

```bash
cd flutter_app
flutter pub get
# Configurar URL do backend em lib/services/api_service.dart
flutter run
```

## 📦 Deploy

### Railway (Backend)

1. Conecte este repositório no Railway
2. Adicione MySQL
3. Configure variáveis de ambiente (JWT_SECRET)
4. Deploy automático!

## 📚 Documentação

- Veja `README.md` para documentação completa
- Veja `flutter_app/README.md` para o app Flutter

## 👤 Usuários de Teste

- Cliente: `cliente@example.com` / `senha123`
- Entregador: `entregador@example.com` / `senha123`
- Admin: `admin@douradelivery.com` / `senha123`

## 📝 Licença

Este projeto é um exemplo de implementação educacional.

---

**Desenvolvido com ❤️ usando Spring Boot e Flutter**

