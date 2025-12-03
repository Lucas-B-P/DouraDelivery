# 🚨 URGENTE: Configure as Variáveis no Railway

## ❌ Erro 502 = Variáveis não configuradas

O erro 502 indica que o backend não consegue iniciar, provavelmente porque **as variáveis de ambiente não estão configuradas no Railway**.

## 🔧 FAÇA AGORA:

### 1. Acesse Railway
- Vá para: https://railway.app
- Entre no seu projeto `DouraDelivery`

### 2. Configure as Variáveis
- Clique em **"Variables"** (no menu lateral)
- Adicione **EXATAMENTE** estas 5 variáveis:

```
DATABASE_URL = jdbc:mysql://shinkansen.proxy.rlwy.net:21574/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

DATABASE_USER = root

DATABASE_PASSWORD = zRTsElBQMXxaLIWpufrQugRdrVZyrUgm

JWT_SECRET = douraDeliverySecretKeyForJWTTokenGeneration2024SuperSecureKey32Chars

PORT = 3000
```

### 3. Salvar e Deploy
- Clique **"Save"** ou **"Add"** para cada variável
- O Railway fará deploy automático
- Aguarde 2-3 minutos

### 4. Testar
```bash
curl https://douradelivery-production.up.railway.app/actuator/health
```

## ⚠️ IMPORTANTE:

- **SEM as variáveis = Erro 502**
- **COM as variáveis = Backend funciona**

## 📱 Como Configurar:

1. **Railway Dashboard** → Seu projeto
2. **Variables** (menu lateral)
3. **Add Variable** para cada uma das 5 variáveis acima
4. **Deploy automático** acontece

---

**🎯 Configure as variáveis AGORA e o erro 502 vai sumir!**
