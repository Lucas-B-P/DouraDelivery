# 🧪 Testar Backend em Produção

## 🌐 URL do Backend

```
https://douradelivery-production.up.railway.app
```

## ✅ Testes Rápidos

### 1. Health Check

```bash
curl https://douradelivery-production.up.railway.app/actuator/health
```

**Resposta esperada:**
```json
{
  "status": "UP"
}
```

### 2. Login (Cliente)

```bash
curl -X POST https://douradelivery-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "cliente@example.com",
    "password": "senha123"
  }'
```

**Resposta esperada:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "cliente@example.com",
  "name": "João Cliente",
  "userType": "CLIENTE",
  "userId": 2
}
```

### 3. Login (Entregador)

```bash
curl -X POST https://douradelivery-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "entregador@example.com",
    "password": "senha123"
  }'
```

### 4. Login (Admin)

```bash
curl -X POST https://douradelivery-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@douradelivery.com",
    "password": "senha123"
  }'
```

## 📱 App Flutter

O app Flutter já está configurado com a URL correta:
- ✅ `lib/services/api_service.dart` → `https://douradelivery-production.up.railway.app`
- ✅ `lib/services/websocket_service.dart` → `wss://douradelivery-production.up.railway.app`

## 🔧 Se o Backend Não Estiver Respondendo

1. Verifique se o deploy foi bem-sucedido no Railway
2. Verifique os logs no Railway
3. Verifique se as variáveis de ambiente estão configuradas
4. Verifique se o MySQL está conectado

## ✅ Pronto!

Backend configurado e pronto para uso! 🎉

