@echo off
REM ===== GIT PUSH AUTOMATIZADO =====
REM Este script faz o git push automaticamente

setlocal enabledelayedexpansion

color 0A
cls

echo ================================================================================
echo                          GIT PUSH AUTOMATICO
echo ================================================================================
echo.

REM ===== VERIFICAR GIT =====
echo [1/4] Verificando Git instalado...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ Git nao esta instalado!
    echo.
    echo Instale de: https://git-scm.com/download/win
    pause
    exit /b 1
) else (
    git --version
    echo ✅ Git encontrado!
)

REM ===== VERIFICAR STATUS GIT =====
echo.
echo [2/4] Verificando status do repositorio...
cd /d "c:\Users\MuriloEduardoOliveir\Downloads\Dash - supabase + github"

git status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ Nao esta em um repositorio Git!
    echo.
    echo Talvez tenha que fazer git clone primeiro.
    pause
    exit /b 1
) else (
    echo ✅ Repositorio encontrado!
)

REM ===== GIT ADD =====
echo.
echo [3/4] Preparando arquivos para commit (git add)...
git add .
if %errorlevel% neq 0 (
    echo ❌ Erro no git add
    pause
    exit /b 1
) else (
    echo ✅ Arquivos preparados!
)

REM ===== GIT COMMIT =====
echo.
echo [4/4] Criando commit e fazendo push...
git commit -m "Deploy Shiny dashboards - Automated"
if %errorlevel% neq 0 (
    echo.
    echo ⚠️ Nada para fazer commit (pode ser ok se nao tem mudancas)
    echo.
)

echo.
echo Fazendo GIT PUSH...
git push origin main
if %errorlevel% neq 0 (
    echo.
    echo ❌ ERRO no git push!
    echo.
    echo Possíveis motivos:
    echo 1. Voce nao esta logado no GitHub
    echo 2. Branch nao existe (tenta "main" ou "master")
    echo 3. Falta permissao no repositorio
    echo.
    pause
    exit /b 1
) else (
    echo.
    echo ✅ GIT PUSH SUCESSO!
)

REM ===== SUCESSO =====
echo.
echo ================================================================================
echo                         TUDO PRONTO!
echo ================================================================================
echo.
echo GitHub Actions vai rodar automaticamente agora!
echo.
echo Veja o progresso em:
echo https://github.com/seu-usuario/seu-repo/actions
echo.
echo Aguarde 10 minutos...
echo.
echo Seus dashboards estarao em:
echo https://m2b29g-muriloargus.shinyapps.io/dashboard_menu/
echo.
echo ================================================================================
echo.

pause
exit /b 0
