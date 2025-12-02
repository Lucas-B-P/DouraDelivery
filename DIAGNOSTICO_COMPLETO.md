# 🔍 Diagnóstico Completo - Backend não responde (502)

## ❌ Problema Atual

O backend está retornando **502 Bad Gateway**, o que significa:
- ✅ O Railway está funcionando
- ❌ A aplicação Spring Boot não está iniciando ou está crashando
- ❌ O app Flutter não consegue conectar

## 🔧 Checklist de Verificação

### 1. Verificar Logs no Railway

**No Railway Dashboard:**
1. Vá em **Deployments**
2. Clique no último deploy
3. Clique em **View Logs**
4. Procure por:

**✅ Sinais de Sucesso:**
```
Started DouraDeliveryApplication
Tomcat started on port(s): 8080
HikariPool-1 - Start completed
```

**❌ Sinais de Erro:**
```
Exception in thread "main"
Error creating bean
Connection refused
Unable to access jarfile
```

### 2. Verificar Variáveis de Ambiente

No Railway, vá em **Settings** → **Variables** e verifique:

**Obrigatórias:**
- ✅ `DATABASE_URL` - Deve ser: `jdbc:mysql://interchange.proxy.rlwy.net:26671/railway?...`
- ✅ `DATABASE_USER` - Usuário do MySQL
- ✅ `DATABASE_PASSWORD` - Senha do MySQL
- ✅ `PORT` - Railway injeta automaticamente (não precisa definir)

**Importante:** Se o Railway tem MySQL conectado, ele pode injetar `DATABASE_URL` automaticamente. Verifique se não há conflito.

### 3. Verificar Build

Nos logs do Railway, procure por:
```
[INFO] BUILD SUCCESS
[INFO] Building jar: /app/target/app.jar
```

Se não aparecer, o build falhou.

### 4. Verificar Inicialização

Nos logs, procure por:
```
Starting DouraDeliveryApplication
```

Se não aparecer, a aplicação não está iniciando.

## 🛠️ Soluções Possíveis

### Solução 1: Verificar se MySQL está conectado

1. No Railway, vá no serviço **MySQL**
2. Verifique se está **Running**
3. Copie a URL de conexão
4. Atualize `DATABASE_URL` no serviço da aplicação

### Solução 2: Verificar se JAR está sendo encontrado

Se os logs mostram "Unable to access jarfile":
- O build pode ter falhado
- O JAR pode ter nome diferente
- Verifique os logs do build

### Solução 3: Verificar porta

Se a aplicação inicia mas Railway não encontra:
- Verifique se está usando `${PORT}` no `application.yml` ✅ (já configurado)
- Verifique se Railway está injetando a variável `PORT`

### Solução 4: Redeploy Manual

1. No Railway, vá em **Deployments**
2. Clique nos **3 pontos** do último deploy
3. Selecione **Redeploy**

## 📋 Informações para Compartilhar

Se o problema persistir, compartilhe:

1. **Últimas 50 linhas dos logs do Railway**
2. **Variáveis de ambiente configuradas** (sem senhas)
3. **Status do MySQL** (Running/Stopped)

## 🧪 Teste Local (Opcional)

Para testar localmente e verificar se o problema é do Railway:

```bash
# Build local
mvn clean package -DskipTests

# Executar
java -jar target/app.jar
```

Se funcionar localmente, o problema é específico do Railway.

---

**Próximo passo: Verifique os logs do Railway e compartilhe o que encontrar! 🔍**

