# 🚀 Variáveis de Ambiente Railway

## ✅ Configure estas variáveis no Railway:

### 1. DATABASE_URL
```
jdbc:mysql://shinkansen.proxy.rlwy.net:21574/railway?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

### 2. DATABASE_USER
```
root
```

### 3. DATABASE_PASSWORD
```
zRTsElBQMXxaLIWpufrQugRdrVZyrUgm
```

### 4. JWT_SECRET
```
douraDeliverySecretKeyForJWTTokenGeneration2024SuperSecureKey32Chars
```

### 5. PORT
```
3000
```

## 🔧 Como configurar no Railway:

1. **Acesse seu projeto no Railway**
2. **Vá em "Variables"**
3. **Adicione cada variável acima**
4. **Clique em "Deploy"**

## ℹ️ Sobre a JWT_SECRET:

A chave JWT pode ser **qualquer string segura** de pelo menos 32 caracteres. Exemplos:

- ✅ `douraDeliverySecretKeyForJWTTokenGeneration2024SuperSecureKey32Chars`
- ✅ `minhaSuperChaveSecreta123456789012345678901234567890`
- ✅ `jwt_secret_key_muito_segura_para_producao_32_caracteres_minimo`

**IMPORTANTE**: Use uma chave diferente em produção!

---

**🎉 Após configurar, o backend deve funcionar perfeitamente!**
