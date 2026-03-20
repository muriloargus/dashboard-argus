# Template Dashboard Shiny
# Crie um novo dashboard a partir deste template

# ==============================================================================
# INSTRUÇÕES DE USO
# ==============================================================================
# 1. Copie esta pasta: /shiny/template_dashboard → /shiny/seu_dashboard_nome
# 2. Edite os parâmetros em "CONFIGURAR AQUI"
# 3. Execute: shiny::runApp()
# 4. Pronto! Dashboard rodando localmente
# ==============================================================================

library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

# ==============================================================================
# CONFIGURAR AQUI - PERSONALIZE SEU DASHBOARD
# ==============================================================================

DASHBOARD_TITLE <- "Dashboard Template"
DASHBOARD_SUBTITLE <- "Seu modelo reutilizável"
DASHBOARD_ICON <- "chart-line"

# Dados - escolha uma:
# Opção 1: CSV local
DATA_SOURCE <- "local"  # ou "supabase"
CSV_PATH <- "../../../input/seu_arquivo.csv"

# Opção 2: Supabase
SUPABASE_URL <- Sys.getenv("SUPABASE_URL")
SUPABASE_KEY <- Sys.getenv("SUPABASE_SERVICE_ROLE_KEY")
SUPABASE_TABLE <- "ativos"  # mudar conforme necessário

# Cores do tema
PRIMARY_COLOR <- "#63a3d8"
SECONDARY_COLOR <- "#e60000"
SUCCESS_COLOR <- "#28a745"
WARNING_COLOR <- "#ffc107"

# ==============================================================================
# FUNÇÕES AUXILIARES
# ==============================================================================

# Conectar ao Supabase
load_data_supabase <- function() {
  tryCatch({
    # Instalar se não tiver: install.packages("supabaseR")
    library(supabaseR)
    
    supabase <- create_client(SUPABASE_URL, SUPABASE_KEY)
    data <- supabase$from(SUPABASE_TABLE)$select("*")$execute()
    
    return(data)
  }, error = function(e) {
    cat("Erro na conexão Supabase:", e$message, "\n")
    return(data.frame())
  })
}

# Carregar CSV
load_data_csv <- function() {
  tryCatch({
    if (file.exists(CSV_PATH)) {
      return(read_csv(CSV_PATH, show_col_types = FALSE))
    } else {
      cat("Arquivo não encontrado:", CSV_PATH, "\n")
      return(data.frame())
    }
  }, error = function(e) {
    cat("Erro ao ler CSV:", e$message, "\n")
    return(data.frame())
  })
}

# Carregar dados (escolhe fonte)
load_data <- function() {
  if (DATA_SOURCE == "supabase") {
    return(load_data_supabase())
  } else {
    return(load_data_csv())
  }
}

# ==============================================================================
# UI (Interface)
# ==============================================================================

ui <- dashboardPage(
  # Header
  dashboardHeader(
    title = span(
      icon(DASHBOARD_ICON),
      DASHBOARD_TITLE,
      style = "color: white;"
    ),
    titleWidth = 350,
    tags$head(
      tags$style(HTML("
        .main-header .logo {
          background-color: #63a3d8;
        }
        .main-header .navbar {
          background-color: #63a3d8;
        }
        .main-header .navbar .sidebar-toggle {
          color: white;
        }
        .main-header a {
          color: white;
        }
      "))
    )
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Sobre", tabName = "sobre", icon = icon("info-circle")),
      
      hr(),
      
      p("Atualizado em:", Sys.time(), style = "padding: 15px; font-size: 12px;"),
      
      br(),
      
      actionButton(
        "refresh_data",
        "🔄 Atualizar Dados",
        width = "100%",
        style = "background-color: #28a745; color: white; border: none; padding: 10px;"
      )
    )
  ),
  
  # Body
  dashboardBody(
    # CSS customizado
    tags$head(
      tags$style(HTML("
        .box {
          border-radius: 8px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .box.box-primary {
          border-top-color: #63a3d8;
        }
        .info-box {
          background: white;
        }
        .stat-number {
          font-size: 32px;
          font-weight: bold;
          color: #63a3d8;
        }
        .stat-label {
          color: #666;
          font-size: 14px;
        }
      "))
    ),
    
    tabsetPanel(
      # ABA 1: Dashboard
      tabPanel(
        "Dashboard",
        value = "dashboard",
        
        # Row 1: KPIs
        fluidRow(
          infoBoxOutput("kpi_1", width = 3),
          infoBoxOutput("kpi_2", width = 3),
          infoBoxOutput("kpi_3", width = 3),
          infoBoxOutput("kpi_4", width = 3)
        ),
        
        # Row 2: Gráficos
        fluidRow(
          box(
            title = "Gráfico 1",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("chart_1", height = "400px")
          ),
          box(
            title = "Gráfico 2",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("chart_2", height = "400px")
          )
        ),
        
        # Row 3: Gráfico grande
        fluidRow(
          box(
            title = "Gráfico 3 (Full Width)",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("chart_3", height = "400px")
          )
        )
      ),
      
      # ABA 2: Dados
      tabPanel(
        "Dados",
        value = "dados",
        
        fluidRow(
          column(
            width = 12,
            
            h3("Tabela de Dados"),
            
            reactableOutput("data_table", height = "600px")
          )
        )
      ),
      
      # ABA 3: Sobre
      tabPanel(
        "Sobre",
        value = "sobre",
        
        fluidRow(
          column(
            width = 8,
            offset = 2,
            
            br(),
            
            h2("Sobre este Dashboard"),
            
            p("Este é um dashboard Shiny baseado em", strong("Argus Platform")),
            
            h4("Características:"),
            tags$ul(
              tags$li("Conexão com Supabase"),
              tags$li("Carregamento de CSVs"),
              tags$li("Gráficos interativos com Plotly"),
              tags$li("Tabelas reativas"),
              tags$li("Tema Bootstrap")
            ),
            
            h4("Fonte de Dados:"),
            p(paste("Fonte:", DATA_SOURCE)),
            
            h4("Dependências:"),
            code("shiny, shinydashboard, plotly, dplyr, readr, reactable"),
            
            br(),
            br(),
            
            p("Desenvolvido com", icon("heart"), "para análise de dados da Ambev CCO")
          )
        )
      )
    )
  )
)

# ==============================================================================
# SERVER (Lógica Reativa)
# ==============================================================================

server <- function(input, output, session) {
  
  # Carregar dados (reativo)
  dados <- reactiveVal(load_data())
  
  # Atualizar dados ao clicar botão
  observeEvent(input$refresh_data, {
    showNotification("Atualizando dados...", type = "message")
    dados(load_data())
    showNotification("Dados atualizados!", type = "default")
  })
  
  # ===========================================================================
  # OUTPUTS - KPIs
  # ===========================================================================
  
  output$kpi_1 <- renderInfoBox({
    df <- dados()
    count <- nrow(df)
    
    infoBox(
      title = "Total de Registros",
      value = count,
      icon = icon("database"),
      color = "blue",
      width = 12
    )
  })
  
  output$kpi_2 <- renderInfoBox({
    infoBox(
      title = "KPI 2",
      value = "XX",
      icon = icon("chart-bar"),
      color = "green",
      width = 12
    )
  })
  
  output$kpi_3 <- renderInfoBox({
    infoBox(
      title = "KPI 3",
      value = "YY",
      icon = icon("users"),
      color = "yellow",
      width = 12
    )
  })
  
  output$kpi_4 <- renderInfoBox({
    infoBox(
      title = "KPI 4",
      value = "ZZ",
      icon = icon("flag"),
      color = "red",
      width = 12
    )
  })
  
  # ===========================================================================
  # OUTPUTS - Gráficos
  # ===========================================================================
  
  output$chart_1 <- renderPlotly({
    df <- dados()
    
    if (nrow(df) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
        layout(title = "Nenhum dado disponível"))
    }
    
    # EXEMPLO: Gráfico simples
    p <- plot_ly(
      df,
      x = ~rownames(df),
      y = ~rep(1, nrow(df)),
      type = "bar",
      marker = list(color = PRIMARY_COLOR)
    ) %>%
    layout(
      title = "Distribuição",
      xaxis = list(title = "Índice"),
      yaxis = list(title = "Contagem"),
      hovermode = "x unified"
    )
    
    return(p)
  })
  
  output$chart_2 <- renderPlotly({
    df <- dados()
    
    if (nrow(df) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
        layout(title = "Nenhum dado disponível"))
    }
    
    # EXEMPLO: Gráfico de pizza
    p <- plot_ly(
      labels = ~c("A", "B", "C"),
      values = ~c(nrow(df) * 0.3, nrow(df) * 0.5, nrow(df) * 0.2),
      type = "pie",
      marker = list(
        colors = c(PRIMARY_COLOR, SECONDARY_COLOR, SUCCESS_COLOR)
      )
    ) %>%
    layout(title = "Proporções")
    
    return(p)
  })
  
  output$chart_3 <- renderPlotly({
    df <- dados()
    
    if (nrow(df) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
        layout(title = "Nenhum dado disponível"))
    }
    
    # EXEMPLO: Linha temporal
    p <- plot_ly(
      x = ~1:nrow(df),
      y = ~seq(1, 100, length.out = nrow(df)),
      type = "scatter",
      mode = "lines+markers",
      line = list(color = PRIMARY_COLOR, width = 2),
      marker = list(size = 6)
    ) %>%
    layout(
      title = "Série Temporal",
      xaxis = list(title = "Tempo"),
      yaxis = list(title = "Valor"),
      hovermode = "x unified"
    )
    
    return(p)
  })
  
  # ===========================================================================
  # OUTPUTS - Tabelas
  # ===========================================================================
  
  output$data_table <- renderReactable({
    df <- dados()
    
    if (nrow(df) == 0) {
      return(reactable(
        data.frame(Mensagem = "Nenhum dado disponível"),
        striped = TRUE
      ))
    }
    
    reactable(
      df %>% head(100),  # Primeiras 100 linhas
      filterable = TRUE,
      searchable = TRUE,
      striped = TRUE,
      highlight = TRUE,
      defaultPageSize = 10,
      pagination = TRUE,
      theme = reactableTheme(
        style = list(fontSize = "13px")
      )
    )
  })
}

# ==============================================================================
# RODAR APP
# ==============================================================================

shinyApp(ui, server)
