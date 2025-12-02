#!/bin/bash

echo "========================================"
echo "  Enviando DouraDelivery para GitHub"
echo "========================================"
echo ""

# Verificar se git está instalado
if ! command -v git &> /dev/null; then
    echo "ERRO: Git não está instalado!"
    echo "Instale Git de: https://git-scm.com/downloads"
    exit 1
fi

echo "[1/5] Inicializando Git..."
if [ ! -d .git ]; then
    git init
    echo "Git inicializado!"
else
    echo "Git já inicializado."
fi

echo ""
echo "[2/5] Adicionando arquivos..."
git add .

echo ""
echo "[3/5] Fazendo commit inicial..."
git commit -m "Initial commit: Backend Spring Boot + App Flutter completo"

echo ""
echo "[4/5] Configurando remote..."
echo ""
echo "IMPORTANTE: Antes de continuar, crie o repositório no GitHub:"
echo "1. Acesse https://github.com"
echo "2. Clique em 'New repository'"
echo "3. Nome: DouraDelivery"
echo "4. NÃO marque 'Initialize with README'"
echo "5. Clique em 'Create repository'"
echo ""

read -p "Digite seu username do GitHub: " GITHUB_USER
read -p "Digite o nome do repositório (ou Enter para 'DouraDelivery'): " REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="DouraDelivery"
fi

echo ""
echo "Configurando remote: https://github.com/$GITHUB_USER/$REPO_NAME.git"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"

echo ""
echo "[5/5] Enviando para GitHub..."
git branch -M main
git push -u origin main

if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO ao enviar!"
    echo "Verifique:"
    echo "- Se o repositório existe no GitHub"
    echo "- Se você tem permissão"
    echo "- Se está autenticado (git config --global user.name e user.email)"
    exit 1
fi

echo ""
echo "========================================"
echo "  SUCESSO! Código enviado para GitHub!"
echo "========================================"
echo ""
echo "Repositório: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""

