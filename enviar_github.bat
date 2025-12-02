@echo off
echo ========================================
echo   Enviando DouraDelivery para GitHub
echo ========================================
echo.

REM Verificar se git está instalado
git --version >nul 2>&1
if errorlevel 1 (
    echo ERRO: Git nao esta instalado!
    echo Instale Git de: https://git-scm.com/downloads
    pause
    exit /b 1
)

echo [1/5] Inicializando Git...
if not exist .git (
    git init
    echo Git inicializado!
) else (
    echo Git ja inicializado.
)

echo.
echo [2/5] Adicionando arquivos...
git add .

echo.
echo [3/5] Fazendo commit inicial...
git commit -m "Initial commit: Backend Spring Boot + App Flutter completo"

echo.
echo [4/5] Configurando remote...
echo.
echo IMPORTANTE: Antes de continuar, crie o repositorio no GitHub:
echo 1. Acesse https://github.com
echo 2. Clique em "New repository"
echo 3. Nome: DouraDelivery
echo 4. NAO marque "Initialize with README"
echo 5. Clique em "Create repository"
echo.
set /p GITHUB_USER="Digite seu username do GitHub: "
set /p REPO_NAME="Digite o nome do repositorio (ou Enter para 'DouraDelivery'): "

if "%REPO_NAME%"=="" set REPO_NAME=DouraDelivery

echo.
echo Configurando remote: https://github.com/%GITHUB_USER%/%REPO_NAME%.git
git remote remove origin 2>nul
git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git

echo.
echo [5/5] Enviando para GitHub...
git branch -M main
git push -u origin main

if errorlevel 1 (
    echo.
    echo ERRO ao enviar!
    echo Verifique:
    echo - Se o repositorio existe no GitHub
    echo - Se voce tem permissao
    echo - Se esta autenticado (git config --global user.name e user.email)
    pause
    exit /b 1
)

echo.
echo ========================================
echo   SUCESSO! Codigo enviado para GitHub!
echo ========================================
echo.
echo Repositorio: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
pause

