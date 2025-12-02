# 🚚 DouraDelivery - Sistema de Roteamento Logístico Automático

Sistema completo de roteamento automático em tempo real para entregas, desenvolvido com Java + Spring Boot e Flutter.

[![Java](https://img.shields.io/badge/Java-17-orange)](https://www.java.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)](https://www.mysql.com/)

## 🚀 Funcionalidades

- ✅ **Autenticação JWT** (Cliente, Entregador, Admin)
- ✅ **Criação de Pedidos** com localização de origem e destino
- ✅ **Roteamento Automático** usando algoritmo greedy com otimizações
- ✅ **Notificações em Tempo Real** via WebSocket
- ✅ **Telemetria GPS** para rastreamento de entregadores
- ✅ **Re-roteamento Dinâmico** quando há mudanças
- ✅ **Painel Administrativo** com métricas e gestão
- ✅ **API REST** completa e documentada
- ✅ **Pronto para App Android** - Veja [ANDROID_INTEGRATION.md](ANDROID_INTEGRATION.md)
- ✅ **React Native** - Veja [REACT_NATIVE_SETUP.md](REACT_NATIVE_SETUP.md)
- ✅ **Flutter** - Veja [FLUTTER_SETUP.md](FLUTTER_SETUP.md) | [Quick Start](FLUTTER_QUICKSTART.md) | [Exemplo Completo](FLUTTER_EXEMPLO_COMPLETO.md)
- ✅ **Gerar APK** - Veja [GERAR_APK.md](GERAR_APK.md)

## 📋 Pré-requisitos

- Java 17+
- Maven 3.9+
- Docker e Docker Compose (para infraestrutura)
- MySQL 8.0+ (ou via Docker)
- Redis (opcional, para cache)
- Kafka (opcional, para eventos)

## 🏗️ Arquitetura

```
Cliente/Entregador/Admin (Web/Mobile)
    ↓ (REST/WebSocket)
API Gateway / Spring Boot
    ├── Controllers (Auth, Cliente, Entregador, Admin)
    ├── Serviços (Routing, Auth, Distance)
    └── WebSocket (Notificações)
    ↓
MySQL (Dados persistentes)
Redis (Cache + Locks)
Kafka (Eventos - opcional)
```

## 🚀 Como Executar

### Opção 1: Docker Compose (Recomendado)

```bash
# Inicia toda a infraestrutura (MySQL, Redis, Kafka)
docker-compose up -d

# Aguarda alguns segundos para os serviços iniciarem
sleep 10

# Compila e executa a aplicação
mvn clean package
java -jar target/logistics-routing-1.0.0.jar
```

### Opção 2: Local

1. **Configure o MySQL:**
```sql
CREATE DATABASE douradelivery;
```

2. **Configure o Redis** (opcional):
```bash
redis-server
```

3. **Execute a aplicação:**
```bash
mvn spring-boot:run
```

A aplicação estará disponível em `http://localhost:8080`

## 📡 Endpoints da API

### Autenticação

- `POST /api/auth/login` - Login (retorna JWT token)
- `POST /api/auth/register` - Registro de usuário

### Cliente

- `POST /api/cliente/pedidos` - Criar novo pedido
- `GET /api/cliente/pedidos` - Listar meus pedidos
- `GET /api/cliente/pedidos/{id}` - Detalhes do pedido

### Entregador

- `GET /api/entregador/pedidos` - Ver pedidos atribuídos
- `POST /api/entregador/pedidos/{id}/aceitar` - Aceitar pedido
- `POST /api/entregador/pedidos/{id}/recusar` - Recusar pedido
- `POST /api/entregador/telemetria` - Enviar localização GPS
- `POST /api/entregador/pedidos/{id}/entregar` - Confirmar entrega
- `GET /api/entregador/rota` - Ver rota atual

### Admin

- `GET /api/admin/pedidos` - Todos os pedidos
- `GET /api/admin/entregadores` - Todos os entregadores
- `GET /api/admin/rotas` - Todas as rotas
- `POST /api/admin/rotas/recalcular` - Forçar recálculo de rotas
- `GET /api/admin/metricas` - Métricas do sistema

### Roteamento

- `POST /api/routes/compute` - Calcular rotas manualmente
- `GET /api/routes` - Listar todas as rotas

## 🔐 Autenticação

Todas as requisições (exceto `/api/auth/**`) requerem o header:

```
Authorization: Bearer <JWT_TOKEN>
```

### Exemplo de Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "cliente@example.com",
    "password": "senha123"
  }'
```

Resposta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "cliente@example.com",
  "name": "João Silva",
  "userType": "CLIENTE",
  "userId": 1
}
```

### Exemplo de Criar Pedido (Cliente)

```bash
curl -X POST http://localhost:8080/api/cliente/pedidos \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "originLat": -23.5505,
    "originLon": -46.6333,
    "destinationLat": -23.5515,
    "destinationLon": -46.6343,
    "weight": 5.0,
    "volume": 0.5,
    "priority": "NORMAL",
    "originAddress": "Rua A, 123",
    "destinationAddress": "Rua B, 456"
  }'
```

## 🔄 WebSocket (Notificações em Tempo Real)

Conecte-se via WebSocket em: `ws://localhost:8080/ws`

### Canais de Notificação

- `/queue/driver/{driverId}` - Notificações para entregador
- `/queue/client/{clientId}` - Notificações para cliente
- `/topic/admin` - Notificações administrativas

### Exemplo de Conexão (JavaScript)

```javascript
const socket = new SockJS('http://localhost:8080/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({}, function(frame) {
  stompClient.subscribe('/queue/driver/1', function(message) {
    const notification = JSON.parse(message.body);
    console.log('Nova notificação:', notification);
  });
});
```

## 🧮 Algoritmo de Roteamento

O sistema utiliza um **algoritmo greedy** otimizado que:

1. Ordena pedidos por prioridade (EXPRESS primeiro) e peso
2. Para cada pedido, encontra o entregador mais próximo com capacidade disponível
3. Calcula distâncias usando fórmula de Haversine (ou OSRM se configurado)
4. Cria/atualiza rotas automaticamente
5. Suporta re-roteamento dinâmico quando há mudanças

### Extensões Futuras

- Integração com **OR-Tools** (Google) para otimização avançada
- Integração com **OSRM/GraphHopper** para rotas reais por estrada
- Clustering espacial (k-means) para agrupar pedidos próximos
- Savings Algorithm (Clarke-Wright) para VRP

## 📊 Modelo de Dados

### Entidades Principais

- **User**: Usuários do sistema (Cliente, Entregador, Admin)
- **Order**: Pedidos de entrega
- **Driver**: Entregadores com localização e capacidade
- **Route**: Rotas atribuídas a entregadores
- **Telemetry**: Dados de GPS em tempo real

## 🔧 Configuração

Edite `src/main/resources/application.yml` para configurar:

- Banco de dados (PostgreSQL)
- Redis (cache)
- Kafka (eventos)
- JWT (secret e expiração)
- OSRM (opcional, para rotas reais)

## 🧪 Testes

```bash
# Executar testes unitários
mvn test

# Executar testes de integração
mvn verify
```

## 📱 App Flutter

**App Flutter completo e funcional!**

Veja a pasta `flutter_app/` com:
- ✅ Código completo e funcional
- ✅ Todas as telas implementadas
- ✅ Integração com backend
- ✅ WebSocket para notificações
- ✅ GPS tracking

**Para começar:**
```bash
cd flutter_app
flutter pub get
# Configure a URL do backend em lib/services/api_service.dart
flutter run
```

Veja `flutter_app/CONFIGURAR.md` para instruções detalhadas.

## 📦 Deploy Backend

### Railway (Recomendado - Mais Fácil)

O projeto está configurado para deploy no Railway.

**Passos rápidos:**
1. Crie conta no [Railway](https://railway.app)
2. Conecte seu repositório GitHub
3. Adicione MySQL (Railway cria automaticamente)
4. Configure variáveis de ambiente (JWT_SECRET)
5. Deploy automático! 🚀

### Docker

```bash
# Build da imagem
docker build -t douradelivery:latest .

# Executar container
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host:5432/douradelivery \
  douradelivery:latest
```

### Kubernetes

Veja exemplos de manifests em `k8s/` (a criar)

## 🛣️ Roadmap

### MVP ✅
- [x] CRUD Orders/Drivers
- [x] Autenticação JWT
- [x] Serviço de roteamento greedy
- [x] WebSocket para notificações
- [x] Telemetria básica
- [x] **App Flutter completo** - Veja `flutter_app/`

### M1 (Próximos passos)
- [ ] Integração OSRM/GraphHopper
- [ ] OR-Tools para otimização avançada
- [ ] Re-optimização incremental
- [ ] Locks distribuídos (Redis)
- [ ] Eventos via Kafka

### M2+ (Produção)
- [ ] Multi-tenant
- [ ] Observability completa (Prometheus, Grafana)
- [ ] Testes E2E
- [ ] Google Maps integrado no app
- [ ] Notificações push nativas

## 📝 Licença

Este projeto é um exemplo de implementação educacional.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## 📞 Suporte

Para dúvidas ou problemas, abra uma issue no repositório.

---

**Desenvolvido com ❤️ usando Spring Boot**

