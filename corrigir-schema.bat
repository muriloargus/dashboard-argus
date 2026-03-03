@echo off
REM Corrigir Schema do Banco de Dados Supabase

echo.
echo ========================================
echo CORRIGIR SCHEMA - BANCO DE DADOS
echo ========================================
echo.

cd /d "%~dp0"

echo 🔧 Executando fix_database_schema.py...
echo.

python fix_database_schema.py

echo.
echo ========================================

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Erro ao executar script automático
    echo.
    echo 📋 INSTRUÇÕES MANUAIS:
    echo 1. Abra: https://app.supabase.com
    echo 2. Vá para "SQL Editor" 
    echo 3. Cole o conteúdo de SQL_SETUP_SUPABASE.sql
    echo 4. Clique "RUN"
    echo 5. Volta e execute: python pipeline.py
    echo.
) else (
    echo.
    echo ✅ Schema corrigido!
    echo.
    echo PRÓXIMO: Execute python pipeline.py
    echo.
)

pause
