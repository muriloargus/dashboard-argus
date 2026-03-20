# 🤖 AUTOMAÇÃO COMPLETA - ARGUS DASHBOARD + SUPABASE

## 📋 Visão Geral

O projeto agora possui **automação em 2 níveis**:

1. **GitHub Actions** (Nuvem) - 3 workflows de sincronização automática
2. **Local (Windows)** - 2 scripts de automação executável

---

## 🌐 AUTOMAÇÃO GITHUB ACTIONS

### ✅ **Workflow 1: Bot Principal (bot.yml)**
- **Quando executa:** A cada 6 horas (ou quando você faz push)
- **O que faz:**
  - 🔍 Verificação de storage (IndexedDB/localStorage)
  - 🚀 Migração automática de dashboards para Supabase
  - 🔄 Pipeline de sincronização CSV → Supabase
  - 📊 Gera relatório de status
  - 💾 Commit automático no GitHub
  
- **Status:** ✅ **CORRIGIDO** (agora usa Node.js v24 compatível)

### ✅ **Workflow 2: Sincronização Geotab (geotab-sync.yml)**
- **Quando executa:** A cada 12 horas (ou manualmente)
- **O que faz:**
  - 🔄 Sincroniza dados do Geotab (via PostgreSQL) → Supabase
  - 📊 Gera relatório de sincronização
  - 💾 Commit automático no GitHub
  
- **Pré-requisito:** Secrets do GitHub configurados

### ✅ **Workflow 3: Deploy e Validação (deploy.yml)**
- **Quando executa:** Quando você faz push de alterações HTML/JS
- **O que faz:**
  - 🔍 Valida todos os arquivos HTML
  - ✅ Verifica integridade dos scripts JS
  - 📈 Gera relatório de dashboards
  - 💾 Commit automático no GitHub

---

## 💻 AUTOMAÇÃO LOCAL (WINDOWS)

### opção 1️⃣ : **RODAR-ORQUESTRADOR.bat** (Simples)
```
🎯 Uso: Clique 2x no arquivo
⏱️  Tempo: ~5-10 minutos
📊 O que faz: Executa 4 bots em sequência + Git push
🔄 Ciclo: Execute manualmente quando desejar sincronizar
```

**Passos:**
1. Clique 2x em `RODAR-ORQUESTRADOR.bat`
2. Aguarde a conclusão (verá mensagens de progresso)
3. Se houver mudanças, será feito push automático para GitHub

**Exemplo de saída:**
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                    🤖 INICIANDO ORQUESTRADOR ARGUS                             ║
║                  Sincronização Automática de Todos os Sistemas                 ║
╚════════════════════════════════════════════════════════════════════════════════╝

✅ Python encontrado
📊 Verificando estrutura de storage (IndexedDB/localStorage)...
✅ Verificação de storage OK

🔄 Migrando dashboards para Supabase (se aplicável)...
✅ Migração OK

🎉 Todos os sistemas sincronizados com sucesso!
```

---

### opção 2️⃣ : **ORQUESTRADOR-AVANCADO.ps1** (Profissional)
```
🎯 Uso: Execute no PowerShell (com privilégios de admin para agendar)
⏱️  Tempo: ~5-10 minutos (ou agendado automaticamente)
📊 O que faz: Executa 4 bots + Git sync + agendamento Windows
🔄 Ciclo: Automático (a cada N horas) ou manual
```

**Para executar uma vez:**
```powershell
.\ORQUESTRADOR-AVANCADO.ps1
```

**Para agendar execução automática (a cada 6 horas):**
```powershell
# Executa PowerShell como Administrador, depois:
.\ORQUESTRADOR-AVANCADO.ps1 -AgendarTarefaWindows -IntervaloCada 6
```

**Opções disponíveis:**
```powershell
-AgendarTarefaWindows    # Agenda no Windows Task Scheduler
-IntervaloCada N         # Intervalo em horas (padrão: 6)
-VerboseOutput           # Saída detalhada
-LogPath "path"          # Caminho do log (padrão: ./logs/orquestrador.log)
```

**Exemplo com agendamento:**
```powershell
# Agendar para executar a cada 12 horas
.\ORQUESTRADOR-AVANCADO.ps1 -AgendarTarefaWindows -IntervaloCada 12
```

---

## 🎯 FLUXO DE AUTOMAÇÃO COMPLETO

```
VOCÊ ADICIONA DADOS (CSV)
           ↓
EXECUTA: RODAR-ORQUESTRADOR.bat (ou PowerShell)
           ↓
   ╔══════════════════════════════════════════╗
   ║      🔍 BOT 1: Verificação Storage       ║
   ║  • Valida IndexedDB/localStorage         ║
   ║  • Gera diagnóstico                      ║
   ╚══════════════════════════════════════════╝
           ↓
   ╔══════════════════════════════════════════╗
   ║   🚀 BOT 2: Migração para Supabase       ║
   ║  • Converte dashboards CSV→Supabase      ║
   ║  • Mantém compatibilidade                ║
   ╚══════════════════════════════════════════╝
           ↓
   ╔══════════════════════════════════════════╗
   ║  🔄 BOT 3: Pipeline Principal            ║
   ║  • CSV → Supabase (sync)                 ║
   ║  • Tabelas ativos, falhas, usuários      ║
   ╚══════════════════════════════════════════╝
           ↓
   ╔══════════════════════════════════════════╗
   ║  🌐 BOT 4: Geotab → Supabase             ║
   ║  • PostgreSQL → Supabase                 ║
   ║  • Dados em tempo real                   ║
   ╚══════════════════════════════════════════╝
           ↓
DADOS ATUALIZADOS NO SUPABASE ✅
           ↓
DASHBOARDS CARREGAM AUTOMATICAMENTE ✨
```

---

## 📊 O QUE CADA BOT FARÁ

### 🔍 **BOT 1: Verificador de Storage**
```python
python bot_verificador_storage.py
```

**Saída esperada:**
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                        🤖 BOT INTELIGENTE - VERIFICADOR DE STORAGE             ║
╚════════════════════════════════════════════════════════════════════════════════╝

📊 ANÁLISE DE DASHBOARDS ANTIGOS (Com IndexedDB/LocalStorage):
  ✅ COM IDB - dashboard_motoristas v2.html
  ✅ COM IDB - dashboard_ativos.html
  ✅ COM IDB - dashboard_usuarios.html
  ...

📊 ANÁLISE DE DASHBOARDS NOVOS (Supabase):
  ✅ SUPABASE - dashboard_ativos_supabase.html
  ✅ SUPABASE - dashboard_falhas_supabase.html
  ...

📈 RESUMO EXECUTIVO:
   ✅ Com IndexedDB/LocalStorage: 11
   ✅ Com Supabase: 3
   ✅ Funcionamento: PERFEITO
```

---

### 🚀 **BOT 2: Migração para Supabase**
```python
python bot_migracao_supabase.py
```

**Saída esperada:**
```
🔄 DASHBOARDS PODEM SER MIGRADOS:
   1. dashboard_motoristas v2.html
      └─ Convertido para: dashboard_motoristas_supabase.html
   
   2. dashboard_desempenho_analista.html
      └─ Convertido para: dashboard_desempenho_supabase.html
   ...

📊 ANÁLISE:
   🔄 Dashboards que podem ser migrados: 7
   ✅ Dashboard já migrado: 3
```

---

### 🔄 **BOT 3: Pipeline Principal**
```python
python pipeline.py
```

**O que sincroniza:**
- `ativos_*.csv` → tabela `ativos` (Supabase)
- `falhas_*.csv` → tabela `falhas` (Supabase)
- `usuarios_*.csv` → tabela `usuarios` (Supabase)
- `excecoes_*.csv` → tabela `excecoes` (Supabase)

**Saída esperada:**
```
[2024-01-15 10:30:45] [INFO] 🔍 Iniciando verificação de dados...
[2024-01-15 10:30:46] [INFO] ✅ Tabelas já existem
[2024-01-15 10:30:47] [INFO] 📁 Lendo arquivo: input/ativos_23-02.csv
[2024-01-15 10:30:48] [INFO] 📤 Enviando 150 registros para Supabase
[2024-01-15 10:30:49] [SUCCESS] ✅ Pipeline concluído com sucesso!
```

---

### 🌐 **BOT 4: Geotab → Supabase**
```python
python pipeline_geotab.py
```

**Sincroniza:**
- PostgreSQL (MyGeotab Adapter) → Supabase

**Saída esperada:**
```
[2024-01-15 10:31:00] [INFO] 🔄 Sincronizando Geotab...
[2024-01-15 10:31:01] [INFO] 📊 Conectado ao Geotab Database
[2024-01-15 10:31:02] [INFO] 📤 Enviando veículos para Supabase
[2024-01-15 10:31:03] [INFO] 📤 Enviando motoristas para Supabase
[2024-01-15 10:31:04] [SUCCESS] ✅ Sincronização Geotab concluída!
```

---

## 📅 AGENDAMENTO AUTOMÁTICO NO WINDOWS

### Opção A: PowerShell (Recomendado)

**Passo 1: Abra PowerShell como Administrador**
```powershell
# Windows + X → PowerShell (Admin)
```

**Passo 2: Execute com agendamento**
```powershell
cd "C:\Users\MuriloEduardoOliveir\Downloads\Dash - supabase + github"
.\ORQUESTRADOR-AVANCADO.ps1 -AgendarTarefaWindows -IntervaloCada 6
```

**Resultado:**
```
✅ Tarefa agendada com sucesso!
Próxima execução: 08:00 - A cada 6 horas
```

---

### Opção B: Task Scheduler (Manual)

**Passo 1: Abra Task Scheduler**
```
Windows + R → taskschd.msc
```

**Passo 2: Create Basic Task**
- Nome: `Argus Bot Automático`
- Descrição: `Sincronização automática de dados`

**Passo 3: Trigger**
- Início: `08:00 AM (quando você desejar)`
- Repetir a cada: `6 horas` (ou seu intervalo)
- Duração: `indefinida`

**Passo 4: Action**
- Programa: `C:\Windows\System32\cmd.exe`
- Argumentos: `/c "C:\Users\MuriloEduardoOliveir\Downloads\Dash - supabase + github\RODAR-ORQUESTRADOR.bat"`

**Passo 5: Finish**
- Clique em "Finish"

---

## 🔐 GITHUB SECRETS NECESSÁRIOS

Para que os workflows funcionem, você precisa configurar 3 secrets:

1. **SUPABASE_URL**
   - Onde encontrar: Supabase Project Settings
   - Exemplo: `https://fnlgstkkkxzrszmxqwwf.supabase.co`

2. **SUPABASE_SERVICE_ROLE_KEY**
   - Onde encontrar: Supabase Project Settings → API → Service Role Key
   - ⚠️ NUNCA compartilhe publicamente!

3. **GEOTAB_DB_PASSWORD** (se usar Geotab)
   - Sua senha do PostgreSQL do Geotab Adapter

**Como adicionar no GitHub:**
1. Vá em: https://github.com/muriloargus/dashboard-argus/settings/secrets/actions
2. Clique em `New repository secret`
3. Adicione cada um dos 3 secrets acima

---

## ✅ VERIFICAÇÃO DO STATUS

### No GitHub Actions
```
https://github.com/muriloargus/dashboard-argus/actions
```

Você verá:
- ✅ **Argus Bot** - Executa a cada 6 horas
- ✅ **Sincronização Geotab** - Executa a cada 12 horas
- ✅ **Deploy Dashboards** - Executa quando você faz push HTML/JS

### Localmente
Verifique a pasta `logs/`:
```
logs/
├── orquestrador.log    ← Log da execução local
├── pipeline.log        ← Log do pipeline CSV
├── sync_geotab.log     ← Log da sincronização Geotab
└── ...
```

**Para visualizar logs em tempo real:**
```powershell
Get-Content logs/orquestrador.log -Wait
```

---

## 🚀 ROTINA RECOMENDADA

### Dia a Dia:
1. **Coloque seus CSVs em:** `./input/` ou na raiz
2. **Execute:** `RODAR-ORQUESTRADOR.bat` (clique 2x)
3. **Pronto!** Dados sincronizados com Supabase

### Semanalmente:
1. Verifique os logs em `./logs/`
2. Confira os dashboards em https://github.com/muriloargus/dashboard-argus/actions
3. Tudo OK? Continue normalmente!

### Mensalmente:
1. Revise se há novos dashboards para migrar
2. Atualize secrets se necessário

---

## 🆘 TROUBLESHOOTING

### ❌ "Python não encontrado"
```
Solução: Instale Python de https://www.python.org/downloads/
Certifique-se de marcar: "Add Python to PATH"
```

### ❌ "Git não encontrado"
```
Solução (opcional): Instale Git de https://git-scm.com/download/win
Sem Git, você terá que fazer push manual
```

### ❌ "ModuleNotFoundError: No module named 'supabase'"
```
Solução: Execute: pip install -r requirements.txt
```

### ❌ Workflow GitHub Actions falhando
```
Verifique: https://github.com/muriloargus/dashboard-argus/actions
Clique no workflow que falhou
Veja os logs de erro
Verifique se SECRETS estão configurados
```

### ❌ Dados não sincronizando
```
Checklist:
1. ✅ .env configurado com SUPABASE_URL e CHAVE?
2. ✅ Arquivo CSV está em ./input/ ?
3. ✅ Formato CSV está correto?
4. ✅ Tabelas existem no Supabase?

Execute: python pipeline.py
Veja os erros no console
```

---

## 📞 RESUMO FINAL

| Componente | Status | Ciclo | Próxima ação |
|-----------|--------|-------|--------------|
| 🤖 Bot Verificação | ✅ Pronto | Manual | Clique em RODAR-ORQUESTRADOR.bat |
| 🚀 Bot Migração | ✅ Pronto | Manual | Clique em RODAR-ORQUESTRADOR.bat |
| 🔄 Bot Pipeline | ✅ Pronto | Manual | Clique em RODAR-ORQUESTRADOR.bat |
| 🌐 Bot Geotab | ✅ Pronto | Manual | Clique em RODAR-ORQUESTRADOR.bat |
| 🌐 GitHub Actions | ✅ Corrigido | A cada 6h | Verifique em /actions |
| 📊 Sincronização Geotab | ✅ Corrigido | A cada 12h | Verifique em /actions |
| 📋 Deploy Dashboards | ✅ Novo | Push automático | Faça push no GitHub |

---

**🎉 Automação completa e funcionando!**
