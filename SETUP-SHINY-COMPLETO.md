# 📊 Setup Completo - Shiny Dashboards Telemetria CCO

## 📋 Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Instalação Rápida](#instalação-rápida)
3. [Instalação Manual](#instalação-manual)
4. [Configurar Supabase](#configurar-supabase)
5. [Deploy Local](#deploy-local)
6. [Deploy Posit Cloud](#deploy-posit-cloud)
7. [GitHub Actions](#github-actions)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Pré-requisitos

### Obrigatório
- **Windows 7+** (ou Mac/Linux)
- **Conexão com internet**
- **Privilégios de administrador** (para instalação)

### Opcional mas Recomendado
- **Git** (https://git-scm.com/)
- **GitHub** (conta)
- **Posit Cloud** (https://posit.cloud)
- **Supabase** (https://supabase.com)

---

## ⚡ Instalação Rápida

### Opção 1: Script Automático (Recomendado)

```bash
SETUP-SHINY.bat
```

Este script fará:
- ✅ Verificar R/RStudio
- ✅ Instalar pacotes Shiny
- ✅ Configurar credenciais
- ✅ Preparar ambiente

**Tempo estimado:** 10-15 minutos

### Opção 2: Manual (Passo a Passo)

Veja seção [Instalação Manual](#instalação-manual) abaixo.

---

## 📥 Instalação Manual

### Passo 1: Instalar R

1. Visite: https://cran.r-project.org/bin/windows/
2. Baixe: **R-4.3.0-win.exe** (ou mais recente)
3. Execute o instalador
4. ⚠️ **IMPORTANTE:** Marque "Add R to PATH"

**Verificar:**
```bash
R --version
```

### Passo 2: Instalar RStudio (Recomendado)

1. Visite: https://posit.co/download/rstudio-desktop/
2. Baixe versão Windows
3. Execute o instalador

### Passo 3: Instalar Pacotes R

Abra **RStudio** e execute:

```r
# Instalar todos os pacotes necessários
packages <- c(
  'shiny',           # Framework Shiny
  'shinydashboard',  # Tema dashboard
  'plotly',          # Gráficos interativos
  'dplyr',           # Manipulação de dados
  'readr',           # Ler CSVs
  'reactable',       # Tabelas interativas
  'rsconnect',       # Deploy Posit Cloud
  'lubridate',       # Manipular datas
  'DBI',             # Conexão banco de dados
  'RPostgres'        # Driver PostgreSQL
)

# Para cada pacote, instale
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
  }
}

# Verificar instalação
library(shiny)
print("✅ Todos os pacotes instalados!")
```

**Tempo estimado:** 5-10 minutos (primeira vez)

### Passo 4: Testar Instalação

No RStudio, execute:

```r
# Carregar Shiny
library(shiny)

# Testar com exemplo
runExample("01_hello")

# Ou testar nossos dashboards
shiny::runApp('shiny/dashboard_menu')
```

Se abrir o dashboard no navegador com sucesso ✅

---

## ☁️ Configurar Supabase

### Para usar dados em nuvem (opcional)

**1. Criar conta Supabase**
- Visite: https://supabase.com
- Seu email + senha
- Confirme email

**2. Criar novo projeto**
- Database name: `telemetria_cco`
- Password: seu-super-segredo
- Region: sa-east-1 (São Paulo)

**3. Obter credenciais**
- Vá em: **Project Settings** → **Database**
- Copie:
  - **Host:** seu-projeto.supabase.co
  - **User:** postgres
  - **Password:** sua-senha (que escolheu)
  - **Port:** 5432

**4. Configurar em app.R**

Edit `shiny/dashboard_ativos_supabase/app.R` e adicione:

```r
# No início do arquivo, após load_data_supabase() :

library(RPostgres)

load_data_supabase <- function() {
  tryCatch({
    con <- dbConnect(
      Postgres(),
      host = "seu-projeto.supabase.co",
      dbname = "postgres",
      user = "postgres",
      password = "sua-senha",
      port = 5432
    )
    
    # Exemplo: carregar tabela ativos
    df <- dbGetQuery(con, "SELECT * FROM ativos LIMIT 1000")
    dbDisconnect(con)
    
    return(df)
  }, error = function(e) {
    message(paste("Erro conexão Supabase:", e$message))
    return(data.frame())
  })
}
```

---

## 🚀 Deploy Local

### Testar cada dashboard

```r
# Dashboard Menu (Home)
shiny::runApp('shiny/dashboard_menu')

# Dashboard Ativos
shiny::runApp('shiny/dashboard_ativos')

# Dashboard Usuários
shiny::runApp('shiny/dashboard_usuarios')

# E assim para todos...
```

**URL local:** `http://localhost:3838`

### Rodar múltiplos dashboards simultaneamente

Abra múltiplas abas do RStudio:
1. Console 1: `shiny::runApp('shiny/dashboard_menu')`
2. Console 2: `shiny::runApp('shiny/dashboard_ativos')`
3. E assim por diante...

Cada um rodará em porta diferente.

---

## ☁️ Deploy Posit Cloud (shinyapps.io)

### Passo 1: Criar Conta Grátis

1. Visite: https://posit.cloud
2. Sign up com email
3. Confirme email

### Passo 2: Gerar Token

1. Clique seu avatar (canto superior direito)
2. My Account → Tokens
3. "Create Token"
4. Copie os 3 valores (account, token, secret)

### Passo 3: Configurar rsconnect

No RStudio:

```r
library(rsconnect)

rsconnect::setAccountInfo(
  account = "seu-usuario",
  token = "seu-token-longo",
  secret = "seu-secret-longo"
)
```

### Passo 4: Deploy Individual

```r
library(rsconnect)

# Deploy um dashboard
rsconnect::deployApp(
  appDir = "shiny/dashboard_menu",
  appName = "dashboard-menu",
  launch.browser = TRUE
)

# Deploy outro
rsconnect::deployApp(
  appDir = "shiny/dashboard_ativos",
  appName = "dashboard-ativos"
)
```

### Passo 5: Deploy Automático (Todos)

Execute o script de deployment:

```bash
Rscript deploy_dashboards.R
```

Ou no RStudio:

```r
source('deploy_dashboards.R')
```

**Resultado esperado:**
```
✅ dashboard_menu: SUCCESS
✅ dashboard_ativos: SUCCESS
✅ dashboard_usuarios: SUCCESS
...
✅ Todos os 15 dashboards deployados!
```

**URLs dos dashboards:**
```
https://seu-usuario.shinyapps.io/dashboard-menu
https://seu-usuario.shinyapps.io/dashboard-ativos
https://seu-usuario.shinyapps.io/dashboard-usuarios
...
```

---

## 🤖 GitHub Actions (CI/CD)

### Passo 1: Adicionar Secrets GitHub

1. Vá em: Repository → Settings → Secrets and variables → Actions
2. Crie 4 novos secrets:

```
POSIT_ACCOUNT_NAME = seu-usuario
POSIT_TOKEN = seu-token
POSIT_SECRET = seu-secret  
POSIT_ACCOUNT_ID = seu-id
```

⚠️ **NÃO compartilhe esses valores!**

### Passo 2: Ativar Workflow

O arquivo `.github/workflows/deploy-shiny.yml` está pronto.

O workflow será acionado automaticamente quando você fizer push em `shiny/`.

### Passo 3: Monitorar Deployments

No GitHub:
- Abra: Actions
- Procure: "Deploy Shiny Dashboards"
- Clique para ver logs

**Status:**
- 🟢 Green: Deploy bem-sucedido
- 🔴 Red: Erro no deploy

---

## 🎯 Estrutura de Diretórios

```
Dash - supabase + github/
│
├── shiny/                           # Todos os 15 dashboards
│   ├── dashboard_menu/
│   │   └── app.R                   # Menu principal / home
│   ├── dashboard_ativos/
│   │   └── app.R                   # Dashboard ativos (CSV)
│   ├── dashboard_usuarios/
│   │   └── app.R                   # Dashboard usuários (CSV)
│   ├── dashboard_motoristas/ 
│   │   └── app.R                   # Dashboard motoristas (CSV)
│   ├── dashboard_falhas/
│   │   └── app.R                   # Dashboard falhas (CSV)
│   ├── dashboard_dispositivos/
│   │   └── app.R                   # Dashboard dispositivos (CSV)
│   ├── dashboard_excecoes/
│   │   └── app.R                   # Dashboard exceções (CSV)
│   ├── dashboard_timeline/
│   │   └── app.R                   # Timeline temporal (CSV)
│   ├── dashboard_temporal_mapas/
│   │   └── app.R                   # Análise geográfica (CSV)
│   ├── dashboard_risco_colisao/
│   │   └── app.R                   # Risco colisão (CSV)
│   ├── dashboard_desempenho_analista/
│   │   └── app.R                   # Desempenho KPI (CSV)
│   ├── dashboard_comparativo/
│   │   └── app.R                   # Comparativo (CSV)
│   ├── dashboard_ativos_supabase/
│   │   └── app.R                   # Ativos (Supabase)
│   ├── dashboard_falhas_supabase/
│   │   └── app.R                   # Falhas (Supabase)
│   └── dashboard_usuarios_supabase/
│       └── app.R                   # Usuários (Supabase)
│
├── .github/
│   └── workflows/
│       └── deploy-shiny.yml        # GitHub Actions workflow
│
├── deploy_dashboards.R              # Script de deployment
├── SETUP-SHINY.bat                 # Setup automático Windows
├── SETUP-SHINY-COMPLETO.md        # Este arquivo
│
├── (Arquivos CSV de dados)
├── (Outros arquivos do projeto)
└── ...
```

---

## 🔍 Troubleshooting

### Erro: "R não está instalado"

**Solução:**
1. Instale R de: https://cran.r-project.org/bin/windows/
2. Asegure-se de marcar "Add R to PATH"
3. Reinicie o Windows
4. Run SETUP-SHINY.bat novamente

### Erro: "Pacotes não encontrados"

**Solução:**
```r
# Instale individualmente
install.packages("shiny", dependencies = TRUE)
install.packages("plotly", dependencies = TRUE)
# ... repeat para cada pacote
```

### "Port 3838 already in use"

**Solução:**
```r
# Rodar em porta diferente
shiny::runApp('shiny/dashboard_menu', port = 3839)
```

### Erro: "Supabase connection timeout"

**Causas:**
- Credenciais erradas
- Firewall bloqueando porta 5432
- Internet lenta

**Solução:**
1. Verifique host/user/password no Supabase
2. Teste conexão: `ping seu-projeto.supabase.co`
3. Verifique firewall/VPN

### Deploy falha no Posit Cloud

**Solução:**
1. Verifique autenticação:
   ```r
   rsconnect::which_account()
   ```

2. Refaça login:
   ```r
   rsconnect::removeAccount("seu-usuario")
   rsconnect::setAccountInfo(account = "...", token = "...", secret = "...")
   ```

3. Deploy individual para teste:
   ```r
   rsconnect::deployApp("shiny/dashboard_menu", appName = "test-menu")
   ```

### GitHub Actions falha

**Verificacions:**
1. Secrets adicionados corretamente? (Settings → Secrets)
2. Token ainda válido? (Posit Cloud)
3. Logs com erro? (Actions → seu workflow)

### Gráficos não aparecem

**Possível causa:** Dados do CSV faltando

**Verificação:**
```r
# Carregue dados manualmente
df <- read.csv("../../../ativos 23-02.csv")
head(df)  # Deve mostrar dados
nrow(df)  # Deve ser > 0
```

---

## 📞 Suporte e Próximos Passos

### Próximas Ações Recomendadas

1. ✅ Execute SETUP-SHINY.bat
2. ✅ Teste dashboard_menu localmente
3. ✅ Configure Posit Cloud
4. ✅ Deploy primeiro dashboard
5. ✅ Configure GitHub Secrets
6. ✅ Teste GitHub Actions
7. ✅ Configure Supabase (opcional)

### Recursos Úteis

- **Shiny Docs:** https://shiny.rstudio.com
- **Posit Cloud:** https://posit.cloud
- **Supabase Docs:** https://supabase.com/docs
- **GitHub Actions:** https://docs.github.com/en/actions

### Documentação do Projeto

- `INDICE-SHINY.md` - Índice geral
- `GUIA-SHINY-RAPIDO.txt` - Guia rápido 6 fases
- `PLANO-CONVERSAO-SHINY.md` - Estratégia de conversão
- `RESUMO-SHINY-CRIADO.txt` - Resumo executivo

---

**Versão:** 1.0.0  
**Atualizado:** Março 2026  
**Status:** ✅ Produção  

🎉 **Bom luck! Vamos lá!** 🚀
