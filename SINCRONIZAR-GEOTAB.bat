@echo off
REM ================================================================
REM  SINCRONIZAR GEOTAB -> SUPABASE
REM  Simplesmente execute este arquivo toda vez que quiser sincronizar
REM ================================================================

cls
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  🚗 SINCRONIZANDO GEOTAB - SUPABASE                       ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERRO: Python não encontrado!
    echo Instale Python em: https://www.python.org
    pause
    exit /b 1
)

REM Ir para a pasta do script
cd /d "%~dp0"

REM Executar o script de sincronização
echo [%date% %time%] Iniciando sincronização...
python sync_geotab_to_supabase.py

if errorlevel 1 (
    echo.
    echo ❌ ERRO durante a sincronização!
    echo Verifique o arquivo sync_geotab.log para detalhes
    pause
    exit /b 1
)

echo.
echo ✅ Sincronização completa!
echo.
echo Dados foram enviados para Supabase.
echo Você pode fechar esta janela.
echo.
pause
