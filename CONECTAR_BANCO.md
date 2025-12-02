# 🗄️ Conectar no Banco de Dados MySQL

## ✅ Configuração Aplicada

A conexão com o MySQL do Railway já está configurada em `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://shinkansen.proxy.rlwy.net:21574/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: root
    password: zRTsElBQMXxaLIWpufrQugRdrVZyrUgm
```

## 🔧 Para Railway (Variáveis de Ambiente)

No Railway, configure as variáveis de ambiente:

```
DATABASE_URL=jdbc:mysql://shinkansen.proxy.rlwy.net:21574/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
DATABASE_USER=root
DATABASE_PASSWORD=zRTsElBQMXxaLIWpufrQugRdrVZyrUgm
```

## 🧪 Testar Conexão Localmente

### Via MySQL CLI

```bash
mysql -h shinkansen.proxy.rlwy.net -P 21574 -u root -p
# Senha: zRTsElBQMXxaLIWpufrQugRdrVZyrUgm
```

### Via Aplicação

Execute a aplicação:

```bash
mvn spring-boot:run
```

A aplicação criará as tabelas automaticamente (ddl-auto: update).

## 📊 Verificar Tabelas

Após executar a aplicação, verifique as tabelas:

```sql
USE railway;
SHOW TABLES;
```

Deve mostrar:
- users
- orders
- drivers
- routes
- telemetry

## ✅ Pronto!

O banco está configurado e pronto para uso!

