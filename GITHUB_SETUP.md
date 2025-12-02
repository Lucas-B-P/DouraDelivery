# 📤 Como Enviar para o GitHub

## 🚀 Passo 1: Criar Repositório no GitHub

1. Acesse [github.com](https://github.com)
2. Clique em **"New repository"** (ou **"+"** → **"New repository"**)
3. Preencha:
   - **Repository name**: `DouraDelivery` (ou o nome que preferir)
   - **Description**: "Sistema de Roteamento Logístico Automático"
   - **Visibility**: Público ou Privado (sua escolha)
   - **NÃO marque** "Initialize with README" (já temos arquivos)
4. Clique em **"Create repository"**

## 📝 Passo 2: Inicializar Git Local

Abra o terminal na pasta do projeto e execute:

```bash
# Inicializar git (se ainda não foi feito)
git init

# Adicionar todos os arquivos
git add .

# Fazer commit inicial
git commit -m "Initial commit: Backend Spring Boot + App Flutter completo"
```

## 🔗 Passo 3: Conectar com GitHub

```bash
# Adicionar remote (substitua SEU_USUARIO pelo seu username do GitHub)
git remote add origin https://github.com/SEU_USUARIO/DouraDelivery.git

# Ou se preferir SSH:
# git remote add origin git@github.com:SEU_USUARIO/DouraDelivery.git
```

## 📤 Passo 4: Enviar para GitHub

```bash
# Enviar código
git branch -M main
git push -u origin main
```

## ✅ Pronto!

Seu código está no GitHub! Acesse:
```
https://github.com/SEU_USUARIO/DouraDelivery
```

## 🔄 Atualizações Futuras

Para enviar atualizações:

```bash
git add .
git commit -m "Descrição das mudanças"
git push
```

## 🚂 Conectar com Railway

1. No Railway, vá em **"New Project"**
2. Selecione **"Deploy from GitHub repo"**
3. Escolha o repositório `DouraDelivery`
4. Railway detectará automaticamente que é Java/Maven
5. Adicione MySQL
6. Configure variáveis de ambiente
7. Deploy automático! 🎉

## 📋 Checklist

- [ ] Repositório criado no GitHub
- [ ] Git inicializado localmente
- [ ] Arquivos commitados
- [ ] Remote configurado
- [ ] Código enviado (push)
- [ ] Repositório conectado no Railway (opcional)

---

**Código no GitHub! 🎉**

