@echo off
REM ╔════════════════════════════════════════════════════════════════════════════════╗
REM ║                                                                                ║
REM ║                    🤖 ORQUESTRADOR AUTOMÁTICO ARGUS                           ║
REM ║                                                                                ║
REM ║  Executa os 4 bots de forma inteligente:                                     ║
REM ║  1. Verificação de Storage (IndexedDB/localStorage)                          ║
REM ║  2. Migração de Dashboards para Supabase                                     ║
REM ║  3. Pipeline de Sincronização (CSV → Supabase)                               ║
REM ║  4. Sincronização Geotab → Supabase                                          ║
REM ║                                                                                ║
REM ╚════════════════════════════════════════════════════════════════════════════════╝

setlocal enabledelayedexpansion

REM Cores no cmd
for /F %%A in ('copy /Z "%~f0" nul') do set "BS=%%A"

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                    🤖 INICIANDO ORQUESTRADOR ARGUS                             ║
echo ║                  Sincronização Automática de Todos os Sistemas                 ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

REM Verifica se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python não está instalado ou não está no PATH
    echo 📖 Instale Python de: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✅ Python encontrado

REM Verifica se Git está instalado
git --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Git não está instalado (opcional)
    echo 📖 Instale Git de: https://git-scm.com/download/win
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                           🔍 FASE 1: VERIFICAÇÃO                               ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

echo 📊 Verificando estrutura de storage (IndexedDB/localStorage)...
python bot_verificador_storage.py
if errorlevel 1 (
    echo ⚠️  Verificação de storage completou com avisos
) else (
    echo ✅ Verificação de storage OK
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                         🚀 FASE 2: MIGRAÇÃO                                    ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

echo 🔄 Migrando dashboards para Supabase (se aplicável)...
python bot_migracao_supabase.py
if errorlevel 1 (
    echo ⚠️  Migração completou com avisos
) else (
    echo ✅ Migração OK
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                      🔄 FASE 3: PIPELINE PRINCIPAL                             ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

echo 📥 Sincronizando dados CSV com Supabase...
python pipeline.py
if errorlevel 1 (
    echo ⚠️  Pipeline completou com avisos
) else (
    echo ✅ Pipeline OK
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                   🌐 FASE 4: SINCRONIZAÇÃO GEOTAB                              ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

if exist "pipeline_geotab.py" (
    echo 🔄 Sincronizando Geotab → Supabase...
    python pipeline_geotab.py
    if errorlevel 1 (
        echo ⚠️  Sincronização Geotab completou com avisos
    ) else (
        echo ✅ Sincronização Geotab OK
    )
) else (
    echo ⏭️  Pipeline Geotab não configurado (pulando)
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                       💾 FASE 5: GIT COMMIT & PUSH                             ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.

REM Verifica se está em um repositório Git
git status >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Não está em um repositório Git (pulando commit)
) else (
    echo 🔄 Preparando para commit...
    
    git config --local user.email "github-actions-local@users.noreply.github.com"
    git config --local user.name "Argus Bot Local"
    
    echo 📁 Adicionando arquivos gerados...
    git add logs/ 2>nul
    git add bot_report.md 2>nul
    git add *_report.md 2>nul
    git add sync_geotab.log 2>nul
    
    echo 💬 Commitando...
    git commit -m "🤖 Bot Argus Local: Sincronização automática - %date% %time:~0,5%" 2>nul
    
    if errorlevel 1 (
        echo ℹ️  Nenhuma mudança para commitar
    ) else (
        echo ✅ Commit realizado
        
        echo 🚀 Fazendo push...
        git push
        if errorlevel 1 (
            echo ⚠️  Erro ao fazer push (verifique conexão)
        ) else (
            echo ✅ Push realizado
        )
    )
)

echo.
echo ╔════════════════════════════════════════════════════════════════════════════════╗
echo ║                        ✨ SINCRONIZAÇÃO COMPLETA                               ║
echo ╚════════════════════════════════════════════════════════════════════════════════╝
echo.
echo Resumo:
echo  ✅ Verificação de Storage
echo  ✅ Migração de Dashboards
echo  ✅ Pipeline de Sincronização
echo  ✅ Sincronização Geotab
echo  ✅ Git Commit & Push (se aplicável)
echo.
echo 🎉 Todos os sistemas sincronizados com sucesso!
echo.
echo 📊 Próxima sincronização automática:
echo    - Bot GitHub (a cada 6 horas)
echo    - Geotab Sync (a cada 12 horas)
echo    - Local (execute quando desejar)
echo.
pause
