# ================================================================
# SINCRONIZAR GEOTAB -> SUPABASE (PowerShell)
# Execute: .\SINCRONIZAR-GEOTAB.ps1
# ================================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚗 SINCRONIZANDO GEOTAB → SUPABASE                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar se estamos na pasta correta
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Verificar se o arquivo .env existe
if (-not (Test-Path ".env")) {
    Write-Host "❌ ERRO: arquivo .env não encontrado!" -ForegroundColor Red
    Write-Host "Copie o conteúdo de .env.geotab.example para seu .env" -ForegroundColor Yellow
    Read-Host "Pressione ENTER para sair"
    exit 1
}

# Verificar se o script Python existe
if (-not (Test-Path "sync_geotab_to_supabase.py")) {
    Write-Host "❌ ERRO: arquivo sync_geotab_to_supabase.py não encontrado!" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit 1
}

# Executar o script
Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Iniciando sincronização..." -ForegroundColor Yellow
Write-Host ""

python sync_geotab_to_supabase.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Sincronização concluída com SUCESSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Dados enviados para Supabase." -ForegroundColor Green
    Write-Host "Próxima sincronização em 15 minutos..." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ ERRO durante a sincronização!" -ForegroundColor Red
    Write-Host "Verifique o arquivo sync_geotab.log para detalhes" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Pressione ENTER para fechar"
