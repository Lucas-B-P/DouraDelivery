# 🔍 Diagnóstico Erro 502 - Railway

## ❌ Problema

Erro 502: "Application failed to respond"

Isso significa que:
- ✅ O Railway conseguiu fazer o build
- ❌ A aplicação não está respondendo na porta correta
- ❌ Ou a aplicação está crashando na inicialização

## 🔧 Correções Aplicadas

### 1. **pom.xml** - Nome do JAR fixo
- ✅ Alterado `finalName` para `app` (sem versão)
- ✅ Garante que o JAR sempre será `app.jar`

### 2. **Dockerfile** - Cópia direta
- ✅ Copia diretamente `app.jar` (sem wildcard)
- ✅ Adiciona variável `PORT` no ENV
- ✅ Passa `--server.port=${PORT:-8080}` no comando

### 3. **application.yml** - Porta dinâmica
- ✅ Já configurado: `port: ${PORT:8080}`

## 🚀 Próximos Passos

### 1. Fazer Commit e Push

```bash
git add .
git commit -m "Fix: Nome do JAR fixo e porta dinâmica para Railway"
git push
```

### 2. Verificar no Railway

1. **Vá em Deployments** no Railway
2. **Aguarde o novo deploy** (pode levar 2-3 minutos)
3. **Verifique os logs**:
   - Procure por: "Started DouraDeliveryApplication"
   - Procure por: "Tomcat started on port(s):"
   - Procure por erros de conexão MySQL

### 3. Possíveis Problemas

#### A) MySQL não conecta
**Sintoma:** Logs mostram erro de conexão MySQL

**Solução:**
- Verifique se as variáveis de ambiente estão configuradas:
  - `DATABASE_URL`
  - `DATABASE_USER`
  - `DATABASE_PASSWORD`

#### B) Porta errada
**Sintoma:** Aplicação inicia mas Railway não encontra

**Solução:**
- Railway injeta `PORT` automaticamente
- A aplicação deve usar essa variável (já configurado)

#### C) Aplicação crasha na inicialização
**Sintoma:** Logs mostram Exception no startup

**Solução:**
- Verifique os logs completos
- Pode ser problema de dependências faltando
- Pode ser problema de configuração

## 🧪 Testar Após Deploy

```bash
# Health Check
curl https://douradelivery-production.up.railway.app/actuator/health

# Se funcionar, testar login
curl -X POST https://douradelivery-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "cliente@example.com", "password": "senha123"}'
```

## 📝 Verificar Logs no Railway

1. Vá em **Deployments** → Último deploy
2. Clique em **View Logs**
3. Procure por:
   - ✅ `Started DouraDeliveryApplication` (sucesso)
   - ❌ `Exception` ou `Error` (problema)

---

**Correções aplicadas! Faça commit e push! 🎉**

