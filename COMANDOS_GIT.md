# 📤 Comandos Git - Enviar para GitHub

## 🚀 Opção 1: Script Automático (Recomendado)

### Windows
```bash
enviar_github.bat
```

### Linux/Mac
```bash
chmod +x enviar_github.sh
./enviar_github.sh
```

## 📝 Opção 2: Manual

### 1. Criar Repositório no GitHub

1. Acesse [github.com](https://github.com)
2. Clique em **"New repository"**
3. Nome: `DouraDelivery`
4. **NÃO marque** "Initialize with README"
5. Clique em **"Create repository"**

### 2. Configurar Git (Primeira vez)

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### 3. Inicializar e Enviar

```bash
# Inicializar git
git init

# Adicionar arquivos
git add .

# Commit inicial
git commit -m "Initial commit: Backend Spring Boot + App Flutter completo"

# Adicionar remote (substitua SEU_USUARIO)
git remote add origin https://github.com/SEU_USUARIO/DouraDelivery.git

# Enviar
git branch -M main
git push -u origin main
```

## 🔄 Atualizações Futuras

```bash
git add .
git commit -m "Descrição das mudanças"
git push
```

## ✅ Verificar

Acesse seu repositório:
```
https://github.com/SEU_USUARIO/DouraDelivery
```

## 🚂 Conectar com Railway

1. No Railway: **"New Project"** → **"Deploy from GitHub repo"**
2. Selecione o repositório `DouraDelivery`
3. Railway detectará automaticamente Java/Maven
4. Adicione MySQL
5. Configure variáveis de ambiente
6. Deploy! 🎉

---

**Código no GitHub! 🎉**

