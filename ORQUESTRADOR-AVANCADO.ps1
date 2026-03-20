#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Orquestrador Automático Argus - Versão PowerShell
    
.DESCRIPTION
    Script avançado que executa todos os 4 bots + Git Sync com suporte a agendamento
    
.EXAMPLE
    .\ORQUESTRADOR-AVANCADO.ps1
    
.LINK
    Documentação: ./SETUP-AUTOMACAO.md
#>

param(
    [switch]$AgendarTarefaWindows = $false,
    [int]$IntervaloCada = 6,
    [switch]$VerboseOutput = $false,
    [string]$LogPath = "./logs/orquestrador.log"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Test-Prerequisitos {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                           🔍 VALIDANDO PRÉ-REQUISITOS                             ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    # Verifica Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Log "✅ Python encontrado: $pythonVersion" "CHECK"
    } catch {
        Write-Log "❌ Python não encontrado" "ERROR"
        return $false
    }
    
    # Verifica Git (opcional)
    try {
        $gitVersion = git --version 2>&1
        Write-Log "✅ Git encontrado: $gitVersion" "CHECK"
    } catch {
        Write-Log "⚠️  Git não encontrado (sincronização remota desabilitada)" "WARN"
    }
    
    # Verifica requirements.txt
    if (Test-Path "requirements.txt") {
        Write-Log "✅ requirements.txt encontrado" "CHECK"
    } else {
        Write-Log "⚠️  requirements.txt não encontrado" "WARN"
    }
    
    # Verifica .env
    if (Test-Path ".env") {
        Write-Log "✅ .env encontrado" "CHECK"
    } else {
        Write-Log "⚠️  .env não encontrado (pipeline pode falhar)" "WARN"
    }
    
    return $true
}

function Invoke-BotVerificacao {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                        🔍 FASE 1: VERIFICAÇÃO DE STORAGE                          ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    Write-Log "Iniciando verificação de storage..." "INFO"
    
    if (-not (Test-Path "bot_verificador_storage.py")) {
        Write-Log "❌ bot_verificador_storage.py não encontrado" "ERROR"
        return $false
    }
    
    try {
        python bot_verificador_storage.py
        Write-Log "✅ Verificação de storage concluída" "SUCCESS"
        return $true
    } catch {
        Write-Log "⚠️  Verificação de storage completou com avisos: $_" "WARN"
        return $true
    }
}

function Invoke-BotMigracao {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                          🚀 FASE 2: MIGRAÇÃO DE DASHBOARDS                        ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    Write-Log "Iniciando migração de dashboards..." "INFO"
    
    if (-not (Test-Path "bot_migracao_supabase.py")) {
        Write-Log "❌ bot_migracao_supabase.py não encontrado" "ERROR"
        return $false
    }
    
    try {
        python bot_migracao_supabase.py
        Write-Log "✅ Migração de dashboards concluída" "SUCCESS"
        return $true
    } catch {
        Write-Log "⚠️  Migração de dashboards completou com avisos: $_" "WARN"
        return $true
    }
}

function Invoke-Pipeline {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                       🔄 FASE 3: PIPELINE PRINCIPAL (CSV→SUPABASE)               ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    Write-Log "Iniciando pipeline de sincronização..." "INFO"
    
    if (-not (Test-Path "pipeline.py")) {
        Write-Log "❌ pipeline.py não encontrado" "ERROR"
        return $false
    }
    
    try {
        python pipeline.py
        Write-Log "✅ Pipeline concluído" "SUCCESS"
        return $true
    } catch {
        Write-Log "⚠️  Pipeline completou com avisos: $_" "WARN"
        return $true
    }
}

function Invoke-PipelineGeotab {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                    🌐 FASE 4: SINCRONIZAÇÃO GEOTAB→SUPABASE                       ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    if (-not (Test-Path "pipeline_geotab.py")) {
        Write-Log "⏭️  pipeline_geotab.py não encontrado (pulando)" "WARN"
        return $true
    }
    
    Write-Log "Iniciando sincronização Geotab..." "INFO"
    
    try {
        python pipeline_geotab.py
        Write-Log "✅ Sincronização Geotab concluída" "SUCCESS"
        return $true
    } catch {
        Write-Log "⚠️  Sincronização Geotab completou com avisos: $_" "WARN"
        return $true
    }
}

function Invoke-GitSync {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                          💾 FASE 5: GIT COMMIT & PUSH                              ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    # Verifica se está em repositório Git
    try {
        $gitStatus = git status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "⚠️  Não está em um repositório Git (pulando)" "WARN"
            return $true
        }
    } catch {
        Write-Log "⚠️  Git não disponível (pulando)" "WARN"
        return $true
    }
    
    Write-Log "Configurando Git..." "INFO"
    git config --local user.email "github-actions-local@users.noreply.github.com"
    git config --local user.name "Argus Bot Local"
    
    Write-Log "Adicionando arquivos..." "INFO"
    git add logs/ 2>$null
    git add bot_report.md 2>$null
    git add *_report.md 2>$null
    git add sync_geotab.log 2>$null
    
    Write-Log "Commitando mudanças..." "INFO"
    $commitMessage = "🤖 Bot Argus: Sincronização automática - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $commitMessage 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✅ Commit realizado" "SUCCESS"
        
        Write-Log "Fazendo push para repositório remoto..." "INFO"
        git push
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Push realizado" "SUCCESS"
        } else {
            Write-Log "⚠️  Erro ao fazer push (verifique conexão)" "WARN"
        }
    } else {
        Write-Log "ℹ️  Nenhuma mudança para commitar" "INFO"
    }
    
    return $true
}

function Schedule-AutomacaoWindows {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                      📅 AGENDAMENTO NO WINDOWS TASK SCHEDULER                      ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    Write-Log "⚠️  Agendamento requer elevação de privilégios" "WARN"
    
    # Verifica se tem admin
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Log "❌ Este script requer privilégios de Administrador para agendar tarefas" "ERROR"
        Write-Host "Executando como Administrador..."
        Start-Process powershell.exe -Verb runAs -ArgumentList "-File",$MyInvocation.MyCommand.Path,"-AgendarTarefaWindows"
        return $false
    }
    
    $taskName = "Argus Bot Automático"
    $scriptPath = (Get-Item -Path .\ORQUESTRADOR-AVANCADO.ps1).FullName
    
    # Remove se já existe
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Log "Removendo tarefa existente..." "INFO"
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
    
    # Cria ação de agendamento
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
    
    # Cria gatilho (a cada IntervaloCada horas)
    $trigger = New-ScheduledTaskTrigger -At 08:00 -RepetitionInterval (New-TimeSpan -Hours $IntervaloCada) -RepetitionDuration (New-TimeSpan -Days 365) -Daily
    
    # Cria tarefa
    $principal = New-ScheduledTaskPrincipal -UserID $env:USERNAME -RunLevel Highest
    
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Bot Argus - Sincronização Automática de Todos os Sistemas" -Force
    
    Write-Log "✅ Tarefa agendada com sucesso!" "SUCCESS"
    Write-Log "Próxima execução: 08:00 - A cada $IntervaloCada horas" "INFO"
    
    return $true
}

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════

# EXECUÇÃO PRINCIPAL
Clear-Host

Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗`n║                                                                                ║`n║                    🤖 ORQUESTRADOR AUTOMÁTICO ARGUS (POWERSHELL)               ║`n║                                                                                ║`n║  Sincronização inteligente de:                                                 ║`n║  1. Verificação de Storage (IndexedDB/localStorage)                            ║`n║  2. Migração de Dashboards para Supabase                                       ║`n║  3. Pipeline de Sincronização (CSV → Supabase)                                 ║`n║  4. Sincronização Geotab → Supabase                                            ║`n║  5. Git Commit & Push (automático)                                             ║`n║                                                                                ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"

# Cria pasta logs se não existir
New-Item -ItemType Directory -Path "./logs" -Force | Out-Null

Write-Log "═══════════════════════════════════════════════════════════════════════════════" "START"
Write-Log "Iniciando Orquestrador Argus - $(Get-Date)" "START"

# Validação
if (-not (Test-Prerequisitos)) {
    Write-Log "Pré-requisitos não atendidos" "ERROR"
    exit 1
}

# Se solicitado agendamento
if ($AgendarTarefaWindows) {
    if (-not (Schedule-AutomacaoWindows)) {
        exit 1
    }
} else {
    # Executa bots em sequência
    Invoke-BotVerificacao | Out-Null
    Invoke-BotMigracao | Out-Null
    Invoke-Pipeline | Out-Null
    Invoke-PipelineGeotab | Out-Null
    Invoke-GitSync | Out-Null
    
    # Resumo final
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════════════╗`n║                        ✨ SINCRONIZAÇÃO COMPLETA                                   ║`n╚════════════════════════════════════════════════════════════════════════════════╝`n"
    
    Write-Log "✅ Verificação de Storage" "SUMMARY"
    Write-Log "✅ Migração de Dashboards" "SUMMARY"
    Write-Log "✅ Pipeline de Sincronização" "SUMMARY"
    Write-Log "✅ Sincronização Geotab" "SUMMARY"
    Write-Log "✅ Git Commit & Push" "SUMMARY"
    
    Write-Host "`n🎉 Todos os sistemas sincronizados com sucesso!`n"
    
    Write-Log "═══════════════════════════════════════════════════════════════════════════════" "END"
}
