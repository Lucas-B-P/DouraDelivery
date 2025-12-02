# 🚂 Configuração Railway - DouraDelivery

## ✅ Banco de Dados Configurado

O MySQL do Railway já está configurado. Agora configure as variáveis de ambiente.

## 🔧 Variáveis de Ambiente no Railway

No serviço da aplicação no Railway, vá em **"Variables"** e adicione:

### Variáveis Obrigatórias

```
DATABASE_URL=jdbc:mysql://shinkansen.proxy.rlwy.net:21574/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
DATABASE_USER=root
DATABASE_PASSWORD=zRTsElBQMXxaLIWpufrQugRdrVZyrUgm
JWT_SECRET=sua_chave_secreta_super_segura_aqui_minimo_32_caracteres
PORT=8080
```

### Variáveis Opcionais

```
REDIS_HOST=seu-redis-host
REDIS_PORT=6379
KAFKA_BOOTSTRAP_SERVERS=seu-kafka-host:9092
```

## 📝 Passo a Passo

1. **No Railway**, acesse seu projeto
2. Clique no serviço da aplicação
3. Vá em **"Variables"** (ou **"Settings"** → **"Variables"**)
4. Clique em **"+ New Variable"**
5. Adicione cada variável acima
6. Salve

## ✅ Verificar

Após configurar, o Railway fará redeploy automaticamente.

Verifique os logs para confirmar que conectou ao banco:
- Procure por: "HikariPool" ou "DataSource"
- Deve aparecer: "HikariPool-1 - Starting..." e depois "HikariPool-1 - Start completed"

## 🧪 Testar

Após o deploy, teste:

```bash
curl https://seu-app.up.railway.app/actuator/health
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

## 🔐 Segurança

**IMPORTANTE:** 
- Não commite as credenciais no código
- Use variáveis de ambiente no Railway
- O arquivo `application.yml` já está configurado para usar variáveis de ambiente

---

**Banco configurado e pronto! 🎉**

