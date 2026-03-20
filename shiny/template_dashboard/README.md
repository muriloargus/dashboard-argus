# 📖 COMO USAR O TEMPLATE SHINY

## 🚀 Começar Rápido

### Passo 1: Instalar Dependências
```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "plotly",
  "dplyr",
  "readr",
  "reactable"
))
```

### Passo 2: Copiar Template para Novo Dashboard
```bash
# Windows PowerShell
xcopy "shiny\template_dashboard" "shiny\dashboard_ativos" /E
# ou manualmente: copie a pasta

# macOS/Linux
cp -r shiny/template_dashboard shiny/dashboard_ativos
```

### Passo 3: Abrir e Personalizar
1. Abra `shiny/dashboard_ativos/app.R` no RStudio
2. Edite as variáveis na seção "CONFIGURAR AQUI":
   ```r
   DASHBOARD_TITLE <- "Dashboard Ativos"
   DASHBOARD_SUBTITLE <- "Rastreamento de Frota"
   CSV_PATH <- "../../../input/ativos_*.csv"
   SUPABASE_TABLE <- "ativos"
   ```

### Passo 4: Rodar Localmente
```r
# No RStudio ou console R:
setwd("shiny/dashboard_ativos")
shiny::runApp()

# Ou use o botão "Run App" no RStudio
```

### Passo 5: Customizar Gráficos
Edite as funções de renderização (`output$chart_1`, etc) para seus dados específicos.

---

## 📋 ESTRUTURA DO TEMPLATE

```
template_dashboard/
├── app.R                    # App principal (tudo-em-um para facilitar)
├── global.R (opcional)      # Código compartilhado
├── ui.R (opcional)          # Interface (se quiser separado)
├── server.R (opcional)      # Lógica (se quiser separado)
└── README.md                # Este arquivo
```

**Nota:** O template usa `app.R` único para facilitar. Se preferir arquivos separados:
- Copie conteúdo `ui` para `ui.R`
- Copie conteúdo `server` para `server.R`
- Use `shiny::runApp("pasta")`

---

## 🎯 PERSONALIZAÇÕES COMUNS

### Mudar Cores do Tema
```r
PRIMARY_COLOR <- "#63a3d8"      # Azul
SECONDARY_COLOR <- "#e60000"    # Vermelho
SUCCESS_COLOR <- "#28a745"      # Verde
WARNING_COLOR <- "#ffc107"      # Amarelo
```

### Carregar Dados do CSV
```r
DATA_SOURCE <- "local"
CSV_PATH <- "../../../input/ativos_23-02.csv"
```

### Carregar Dados do Supabase
```r
DATA_SOURCE <- "supabase"
SUPABASE_TABLE <- "ativos"  # ou "falhas", "usuarios", etc
```

### Adicionar Nova Aba
```r
tabPanel(
  "Nova Aba",
  value = "nova_aba",
  
  h2("Conteúdo aqui"),
  plotlyOutput("novo_grafico")
)
```

### Adicionar Novo Gráfico
```r
output$novo_grafico <- renderPlotly({
  df <- dados()
  
  plot_ly(df, x = ~coluna1, y = ~coluna2, type = "scatter")
})
```

---

## 🔌 INTEGRAÇÃO SUPABASE

### Instalar RPostgres (para PostgreSQL/Geotab)
```r
install.packages(c("DBI", "RPostgres"))
```

### Exemplo: Conectar ao Geotab
```r
library(DBI)
library(RPostgres)

conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = "mygeotab_adapter",
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = Sys.getenv("DB_PASSWORD")
)

dados <- dbGetQuery(conn, "SELECT * FROM tabela_geotab")
```

---

## 📦 ESTRUTURA PARA 14 DASHBOARDS

Após clonar template para cada dashboard:

```
shiny/
├── template_dashboard/           # Referência
├── dashboard_ativos/             # CSS
├── dashboard_motoristas/         # CSV
├── dashboard_usuarios/           # CSV
├── dashboard_falhas/             # CSV + Supabase
├── dashboard_excecoes/           # CSV
├── dashboard_comparativo/        # CSV
├── dashboard_desempenho/         # CSV
├── dashboard_dispositivos/       # CSV
├── dashboard_timeline/           # CSV
├── dashboard_risco_colisao/      # CSV
├── dashboard_temporal_mapas/     # CSV
├── dashboard_ativos_supabase/    # Supabase
├── dashboard_falhas_supabase/    # Supabase
└── dashboard_usuarios_supabase/  # Supabase
```

Cada pasta é uma cópia do template com dados específicos.

---

## 🚀 DEPLOY NO POSIT CLOUD

### 1. Account Setup
```
1. Acesse: posit.cloud
2. Make → New Project
3. Git → Cole URL do seu repositório
```

### 2. Deploy via rsconnect
```r
install.packages("rsconnect")
rsconnect::setAccountInfo(
  account = "seu_usuario",
  token = "seu_token",
  secret = "seu_secret"
)

# Deploy este app
rsconnect::deployApp("shiny/dashboard_ativos")
```

### 3. Deploy Automático (GitHub Actions)
Ver `.github/workflows/deploy_shiny.yml`

---

## 🐛 TROUBLESHOOTING

### "Erro: objeto 'dados' não encontrado"
**Solução:** Certifique-se que `load_data()` não retornou `NULL`

### "CSV não carregado"
**Solução:** Verifique:
- Caminho do arquivo (`CSV_PATH`)
- Arquivo existe em `input/`
- Formato está correto (CSV com virgula/ponto-e-vírgula)

### "Supabase authentication failed"
**Solução:**
```r
# No console:
Sys.setenv(SUPABASE_URL = "sua_url")
Sys.setenv(SUPABASE_SERVICE_ROLE_KEY = "sua_chave")
```

### "Plotly não renderiza"
**Solução:** Verifique se dados não estão vazios:
```r
if (nrow(df) == 0) return(plotly_empty())
```

---

## 📚 RECURSOS

- **Shiny Docs:** https://shiny.posit.co
- **Plotly R:** https://plotly.com/r
- **shinydashboard:** https://rstudio.github.io/shinydashboard
- **Supabase R:** https://github.com/dcassol/supabaseR

---

## ✅ CHECKLIST DE CUSTOMIZAÇÃO

Para cada novo dashboard:

- [ ] Copiou template?
- [ ] Editou `DASHBOARD_TITLE` e `DASHBOARD_SUBTITLE`?
- [ ] Define `DATA_SOURCE` (local ou supabase)?
- [ ] Define caminho do CSV ou tabela Supabase?
- [ ] Rodou localmente com `shiny::runApp()`?
- [ ] Personalizou gráficos para seus dados?
- [ ] Testou interpolação de dados?
- [ ] Salvou e commitou no Git?

---

**Pronto! Seu dashboard Shiny está funcionando! 🎉**
