# 🌐 URL do Backend Configurada

## ✅ URL do Backend

**Produção (Railway):**
```
https://douradelivery-production.up.railway.app
```

**Porta TCP:** 3030 (usada internamente pelo Railway)

## 📱 App Flutter

A URL já está configurada em:
- `flutter_app/lib/services/api_service.dart`
- `flutter_app/lib/services/websocket_service.dart`

## 🧪 Testar Conexão

### Health Check
```bash
curl https://douradelivery-production.up.railway.app/actuator/health
```

### Login
```bash
curl -X POST https://douradelivery-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "cliente@example.com",
    "password": "senha123"
  }'
```

## ✅ Pronto!

O app Flutter agora está configurado para usar o backend em produção!

