@echo off
REM ===== SETUP COMPLETO SHINY DASHBOARDS - WINDOWS =====
REM Este script configura um ambiente completo para Shiny
REM Requer: Windows 7+ e conexão com internet

setlocal enabledelayedexpansion

color 0A
cls

echo ================================================================================
echo             SETUP COMPLETO - SHINY DASHBOARDS TELEMETRIA CCO
echo ================================================================================
echo.
echo Este script irá:
echo   1. Verificar se R está instalado
echo   2. Verificar se RStudio está instalado  
echo   3. Instalar pacotes R necessários
echo   4. Configurar Supabase (opcional)
echo   5. Configurar Posit Cloud para deployment
echo.

pause

REM ===== VERIFICAR R =====
echo.
echo [1/5] Verificando R...
R --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ R não está instalado!
    echo.
    echo Abra: https://cran.r-project.org/bin/windows/
    echo Baixe: R-4.3.0-win.exe (ou mais recente)
    echo Instale com opção de adicionar ao PATH
    echo.
    echo Depois execute este script novamente.
    pause
    exit /b 1
) else (
    echo ✅ R encontrado!
    for /f "tokens=*" %%A in ('R --version ^| findstr /R "^R version"') do echo %%A
)

REM ===== VERIFICAR RSTUDIO =====
echo.
echo [2/5] Verificando RStudio...
where Rstudio.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  RStudio não está instalado (opcional)
    echo.
    echo Você pode instalar do link abaixo para melhor experiência:
    echo https://posit.co/download/rstudio-desktop/
    echo.
    echo Pressione ENTER para continuar...
    pause
) else (
    echo ✅ RStudio encontrado!
)

REM ===== INSTALAR PACOTES R =====
echo.
echo [3/5] Instalando pacotes R necessários...
echo.
echo Isso pode levar alguns minutos (5-15 min)...
echo.

Rscript --vanilla -e "
cat('Instalando pacotes necessários...\n')
cat('========================================\n')

pkgs <- c('shiny', 'shinydashboard', 'plotly', 'dplyr', 'readr', 'reactable', 'rsconnect', 'lubridate', 'DBI', 'RPostgres')

for (pkg in pkgs) {
  if (!require(pkg, character.only = TRUE)) {
    cat('Instalando:', pkg, '...')
    install.packages(pkg, quiet = TRUE, dependencies = TRUE)
    cat(' ✅\n')
  } else {
    cat('✅', pkg, '(já instalado)\n')
  }
}

cat('\n========================================\n')
cat('✅ Todos os pacotes instalados com sucesso!\n')
"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Erro ao instalar pacotes!
    echo.
    echo Tente manualmente no RStudio:
    echo install.packages(c('shiny', 'shinydashboard', 'plotly', 'dplyr', 'readr', 'reactable', 'rsconnect'))
    echo.
    pause
    exit /b 1
)

REM ===== CONFIGURAR SUPABASE =====
echo.
echo [4/5] Supabase (opcional)
echo.
echo Para usar dados do Supabase:
echo.
echo 1. Abra https://supabase.com e faça login
echo 2. Vá em Project Settings ^> Database
echo 3. Copie os dados de conexão
echo 4. Edite os app.R dos dashboards _supabase com suas credenciais
echo.
echo Host: seu-projeto.supabase.co
echo User: postgres
echo Password: sua-senha
echo.
echo Pressione ENTER para continuar...
pause

REM ===== CONFIGURAR POSIT CLOUD =====
echo.
echo [5/5] Configurar Posit Cloud (shinyapps.io)
echo.
echo Para fazer deploy automático:
echo.
echo 1. Crie conta em https://posit.cloud (gratuito)
echo 2. Clique em seu avatar (canto direito)
echo 3. Selecione "Tokens"
echo 4. Crie um novo token
echo 5. Execute o comando abaixo no RStudio:
echo.
echo rsconnect::setAccountInfo(
echo   account = 'seu-user',
echo   token = 'token-aqui',
echo   secret = 'secret-aqui'
echo )
echo.
echo Pressione ENTER para continuar...
pause

REM ===== CRIAR DIRETÓRIOS =====
echo.
echo Criando estrutura de diretórios...

if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "config" mkdir config

echo ✅ Diretórios criados/verificados

REM ===== TESTE SHINY =====
echo.
echo ================================================================================
echo SETUP CONCLUÍDO COM SUCESSO!
echo ================================================================================
echo.
echo PRÓXIMOS PASSOS:
echo.
echo 1. Para testar localmente:
echo    Abra RStudio
echo    Na console, digite:
echo    shiny::runApp('shiny/dashboard_menu')
echo.
echo 2. Para testar outro dashboard:
echo    shiny::runApp('shiny/dashboard_ativos')
echo.
echo 3. Para ver todos os dashboards:
echo    dir shiny\
echo.
echo 4. Para fazer deploy no Posit Cloud:
echo    Execute: Rscript deploy_dashboards.R
echo.
echo 5. Para GitHub Actions setup:
echo    Adicione secrets no GitHub:
echo    - POSIT_TOKEN
echo    - POSIT_ACCOUNT_NAME
echo    - POSIT_ACCOUNT_ID
echo    - POSIT_SECRET
echo.
echo ================================================================================
echo.
echo Documentação: Abra SETUP-SHINY-COMPLETO.md para instruções detalhadas
echo.

pause
exit /b 0
