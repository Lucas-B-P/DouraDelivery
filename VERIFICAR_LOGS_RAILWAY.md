# 📋 Como Verificar Logs no Railway

## 🔍 Passo a Passo

### 1. Acesse o Railway Dashboard
- Vá em [railway.app](https://railway.app)
- Faça login
- Selecione seu projeto **DouraDelivery**

### 2. Vá em Deployments
- Clique no serviço **DouraDelivery** (não o MySQL)
- Clique na aba **Deployments**
- Clique no **último deploy** (o mais recente)

### 3. Veja os Logs
- Clique em **View Logs** ou **Logs**
- Role para baixo para ver os logs mais recentes

### 4. O que Procurar

#### ✅ Se estiver funcionando:
```
Started DouraDeliveryApplication in X.XXX seconds
Tomcat started on port(s): 8080
HikariPool-1 - Start completed
```

#### ❌ Se houver erro:

**Erro de JAR:**
```
Error: Unable to access jarfile app.jar
```
**Solução:** Build falhou ou JAR não foi gerado

**Erro de MySQL:**
```
Communications link failure
Access denied for user
```
**Solução:** Verificar `DATABASE_URL`, `DATABASE_USER`, `DATABASE_PASSWORD`

**Erro de Porta:**
```
Port 8080 is already in use
```
**Solução:** Railway deve injetar `PORT` automaticamente

**Erro de Build:**
```
[ERROR] BUILD FAILURE
```
**Solução:** Verificar erros de compilação nos logs

## 📸 Compartilhar Logs

Se precisar de ajuda:
1. Copie as últimas 50-100 linhas dos logs
2. Procure por palavras-chave: `ERROR`, `Exception`, `Failed`
3. Compartilhe aqui

---

**Verifique os logs e me diga o que encontrou! 🔍**

