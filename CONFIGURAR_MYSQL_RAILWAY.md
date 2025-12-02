# 🔧 Como Configurar MySQL no Railway

## ❌ Problema Atual

A aplicação não consegue conectar ao MySQL. Erro:
```
CommunicationsException: Communications link failure
```

## ✅ Solução Passo a Passo

### 1. Verificar Variáveis do MySQL no Railway

1. No Railway Dashboard, clique no serviço **MySQL**
2. Vá em **Variables** (ou **Connect** → **Variables**)
3. **Copie todas as variáveis** que aparecem, por exemplo:
   - `MYSQLHOST` ou `MYSQL_HOST`
   - `MYSQLPORT` ou `MYSQL_PORT`  
   - `MYSQLDATABASE` ou `MYSQL_DATABASE`
   - `MYSQLUSER` ou `MYSQL_USER`
   - `MYSQLPASSWORD` ou `MYSQL_PASSWORD`

### 2. Configurar no Serviço da Aplicação

1. No Railway Dashboard, clique no serviço **DouraDelivery** (aplicação)
2. Vá em **Variables**
3. Adicione/Atualize as seguintes variáveis:

**Se o Railway injeta automaticamente (recomendado):**
- O Railway pode injetar automaticamente se os serviços estão conectados
- Verifique se já existem variáveis como `MYSQLHOST`, `MYSQLPORT`, etc.
- Se existirem, a aplicação já deve usar (já configurado no `application.yml`)

**Se precisar configurar manualmente:**
```
DATABASE_URL=jdbc:mysql://[HOST_DO_MYSQL]:[PORTA]/[DATABASE]?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
DATABASE_USER=[USUARIO]
DATABASE_PASSWORD=[SENHA]
```

**Substitua:**
- `[HOST_DO_MYSQL]` pelo valor de `MYSQLHOST` do serviço MySQL
- `[PORTA]` pelo valor de `MYSQLPORT` do serviço MySQL
- `[DATABASE]` pelo valor de `MYSQLDATABASE` do serviço MySQL
- `[USUARIO]` pelo valor de `MYSQLUSER` do serviço MySQL
- `[SENHA]` pelo valor de `MYSQLPASSWORD` do serviço MySQL

### 3. Exemplo Prático

Se no serviço MySQL você vê:
```
MYSQLHOST=containers-us-west-123.railway.app
MYSQLPORT=3306
MYSQLDATABASE=railway
MYSQLUSER=root
MYSQLPASSWORD=abc123xyz
```

Configure no serviço DouraDelivery:
```
DATABASE_URL=jdbc:mysql://containers-us-west-123.railway.app:3306/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
DATABASE_USER=root
DATABASE_PASSWORD=abc123xyz
```

### 4. Salvar e Aguardar Redeploy

1. Clique em **Save** ou **Update**
2. O Railway fará redeploy automaticamente
3. Aguarde 2-3 minutos
4. Verifique os logs

### 5. Verificar Sucesso

Nos logs, procure por:
```
HikariPool-1 - Start completed
Started DouraDeliveryApplication
```

Se aparecer, a conexão funcionou! ✅

## 🔍 Dica Importante

**O Railway pode injetar variáveis automaticamente!**

Se você conectou o MySQL ao projeto, o Railway pode criar variáveis automaticamente no serviço da aplicação. Verifique se já existem variáveis como:
- `MYSQLHOST`
- `MYSQLPORT`
- `MYSQLDATABASE`
- `MYSQLUSER`
- `MYSQLPASSWORD`

Se existirem, a aplicação já está configurada para usá-las! ✅

---

**Configure as variáveis e faça redeploy! 🚀**

