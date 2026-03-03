@echo off
REM ⚡ RESOLVA-TUDO - Fix automático para problemas

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  ⚡ RESOLVA-TUDO - Corrigindo problemas de uma vez            ║
echo ║  Este script instala módulos e prepara o ambiente              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verifica Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python não encontrado!
    echo.
    echo Instale em: https://www.python.org/downloads
    pause
    exit /b 1
)

echo ✅ Python encontrado
echo.

REM Instala dependências
echo 📦 Instalando dependências Python...
echo.

pip install -q supabase python-dotenv pandas requests

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Dependências instaladas com sucesso!
) else (
    echo.
    echo ❌ Erro ao instalar dependências
    pause
    exit /b 1
)

echo.
echo 📁 Verificando pastas...

if not exist "input" (
    mkdir input
    echo ✅ Pasta input/ criada
) else (
    echo ✅ Pasta input/ já existe
)

echo.
echo ════════════════════════════════════════════════════════════════════
echo.
echo ✅ AMBIENTE PRONTO!
echo.
echo 🚀 PRÓXIMOS PASSOS:
echo.
echo 1. Coloque seus CSVs em:
echo    C:\Users\muril\Downloads\dashboard_argus\input\
echo.
echo 2. Abra PowerShell (sem fechar esta janela)
echo.
echo 3. Execute:
echo    cd C:\Users\muril\Downloads\dashboard_argus
echo    python pipeline.py
echo.
echo 4. Espere aparecer: ✅ Pipeline concluído!
echo.
echo ════════════════════════════════════════════════════════════════════
echo.

pause
