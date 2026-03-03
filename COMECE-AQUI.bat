@echo off
REM Setup simplificado para Windows
REM Clique neste arquivo para começar

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  🚀 ARGUS DASHBOARD - SETUP AUTOMÁTICO                    ║
echo ║  Sistema vai configurar tudo automaticamente               ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Verifica se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ PYTHON NÃO INSTALADO!
    echo.
    echo Baixe Python em: https://www.python.org/downloads/
    echo Marque: "Add Python to PATH"
    pause
    exit /b 1
)

echo ✅ Python encontrado!
echo.
echo 📦 Instalando dependências...
python -m pip install -q python-dotenv

echo.
echo 🚀 Executando setup...
python setup.py

if errorlevel 0 (
    echo.
    echo ✅ SETUP COMPLETADO COM SUCESSO!
    echo.
    echo 📋 PRÓXIMAS INSTRUÇÕES:
    echo 1. Abra arquivo: GUIA-VISUAL-SUPER-SIMPLES.txt
    echo 2. Siga cada passo
    echo.
) else (
    echo.
    echo ❌ Erro no setup. Tente novamente.
)

pause
