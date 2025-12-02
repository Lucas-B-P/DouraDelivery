# 🔄 Atualizar URL do Banco de Dados - Railway

## ✅ Nova URL Configurada

**Nova URL do MySQL:**
```
interchange.proxy.rlwy.net:26671
```

## 📝 Configuração Atualizada

O arquivo `application.yml` foi atualizado com a nova URL:

```yaml
spring:
  datasource:
    url: jdbc:mysql://interchange.proxy.rlwy.net:26671/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

## 🔧 Variáveis de Ambiente no Railway

No Railway Dashboard, atualize a variável `DATABASE_URL`:

1. Vá em **Settings** → **Variables**
2. Encontre `DATABASE_URL`
3. Atualize para:
   ```
   jdbc:mysql://interchange.proxy.rlwy.net:26671/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
   ```
4. Salve

**OU** deixe o Railway usar a variável de ambiente automática do MySQL.

## 🚀 Próximos Passos

### 1. Commit e Push

```bash
git add .
git commit -m "Update: Nova URL do MySQL Railway"
git push
```

### 2. Verificar no Railway

Após o deploy, verifique os logs:
- Procure por: `HikariPool-1 - Start completed`
- Procure por: `Started DouraDeliveryApplication`

### 3. Testar Conexão

```bash
curl https://douradelivery-production.up.railway.app/actuator/health
```

Deve retornar:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    }
  }
}
```

## ✅ Pronto!

Nova URL do banco configurada! 🎉

