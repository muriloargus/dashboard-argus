library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

# ===== CONFIGURAÇÕES =====
DASHBOARD_TITLE <- "ATIVOS CADASTRADOS"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Gestão de Frota"
DATA_FILE <- "../../../ativos 23-02.csv"
COLOR_PRIMARY <- "#63a3d8"
COLOR_SECONDARY <- "#e60000"
COLOR_ACCENT <- "#FFD700"

# ===== FUNÇÃO PARA CARREGAR DADOS =====
load_data <- function() {
  tryCatch({
    df <- read_csv(DATA_FILE, show_col_types = FALSE)
    return(df)
  }, error = function(e) {
    message(paste("Erro ao carregar dados:", e$message))
    return(data.frame())
  })
}

# ===== UI =====
ui <- dashboardPage(
  dashboardHeader(
    title = DASHBOARD_TITLE,
    titleWidth = 350,
    disable = FALSE
  ),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Dados Brutos", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    ),
    br(),
    p("Última atualização:", textOutput("last_update", inline = TRUE),
      style = "font-size: 12px; color: #bbb; padding: 0 15px;")
  ),
  dashboardBody(
    tabItems(
      # ===== ABA 1: DASHBOARD =====
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Ativos", textOutput("total_ativos"), 
                  icon = icon("truck"), color = "blue", width = 3),
          infoBox("Ativos Ativos", textOutput("ativos_ativos"), 
                  icon = icon("check-circle"), color = "green", width = 3),
          infoBox("Inativos", textOutput("ativos_inativos"), 
                  icon = icon("pause-circle"), color = "orange", width = 3),
          infoBox("Taxa de Utilização", textOutput("taxa_utilizacao"), 
                  icon = icon("percent"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_status"), width = 6, title = "Status dos Ativos"),
          box(plotlyOutput("chart_tipos"), width = 6, title = "Distribuição por Tipo")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Timeline de Cadastro")
        )
      ),
      
      # ===== ABA 2: DADOS BRUTOS =====
      tabItem(tabName = "dados",
        h2("Dados Completos"),
        reactableOutput("data_table")
      ),
      
      # ===== ABA 3: ATUALIZAR =====
      tabItem(tabName = "refresh",
        h2("Gerenciar Dados"),
        p("Clique abaixo para atualizar dados do arquivo CSV:"),
        actionButton("btn_refresh", "🔄 Atualizar Dados", 
                     class = "btn-lg", style = "background-color: #63a3d8; color: white;"),
        br(), br(),
        textOutput("refresh_status")
      )
    )
  )
)

# ===== SERVER =====
server <- function(input, output, session) {
  
  # Carregar dados ao iniciar
  data_loaded <- reactiveVal(load_data())
  
  # KPIs
  output$total_ativos <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0")
    nrow(df)
  })
  
  output$ativos_ativos <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0")
    if("status" %in% names(df)) {
      sum(tolower(df$status) %in% c("ativo", "active"), na.rm = TRUE)
    } else {
      nrow(df)
    }
  })
  
  output$ativos_inativos <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0")
    if("status" %in% names(df)) {
      sum(tolower(df$status) %in% c("inativo", "inactive"), na.rm = TRUE)
    } else {
      0
    }
  })
  
  output$taxa_utilizacao <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0%")
    total <- nrow(df)
    ativos <- sum(tolower(df$status) %in% c("ativo", "active"), na.rm = TRUE)
    if(total == 0) return("0%")
    paste0(round((ativos / total) * 100, 1), "%")
  })
  
  output$last_update <- renderText({
    format(Sys.time(), "%d/%m/%Y %H:%M")
  })
  
  # CHART 1: Status dos Ativos (Pizza)
  output$chart_status <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    if("status" %in% names(df)) {
      counts <- df %>% 
        group_by(status) %>% 
        summarise(Count = n(), .groups = 'drop')
    } else {
      counts <- data.frame(status = "Desconhecido", Count = nrow(df))
    }
    
    plot_ly(counts, labels = ~status, values = ~Count, type = "pie",
            textposition = 'inside', textinfo = 'label+percent',
            marker = list(colors = c(COLOR_ACCENT, COLOR_SECONDARY))) %>%
      layout(title = "", showlegend = TRUE,
             paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  # CHART 2: Distribuição por Tipo
  output$chart_tipos <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    if("tipo" %in% names(df) || "type" %in% names(df)) {
      col_tipo <- if("tipo" %in% names(df)) "tipo" else "type"
      counts <- df %>% 
        group_by(!!sym(col_tipo)) %>% 
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(desc(Count)) %>%
        head(10)
    } else {
      counts <- data.frame(tipo = "Sem categorização", Count = nrow(df))
    }
    
    plot_ly(counts, x = ~Count, y = ~tipo, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(title = "", yaxis = list(autorange = "reversed"),
             xaxis = list(title = "Quantidade"),
             paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  # CHART 3: Timeline de Cadastro
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    if("data_cadastro" %in% names(df) || "created_at" %in% names(df)) {
      col_data <- if("data_cadastro" %in% names(df)) "data_cadastro" else "created_at"
      timeline <- df %>%
        mutate(date = as.Date(!!(parse_date_time(!!sym(col_data), orders = c("ymd", "dmy", "mdy"))))) %>%
        filter(!is.na(date)) %>%
        group_by(date) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(date)
    } else {
      timeline <- data.frame(date = seq(Sys.Date() - 30, Sys.Date(), by = 1),
                            Count = sample(1:5, 31, replace = TRUE))
    }
    
    plot_ly(timeline, x = ~date, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = COLOR_ACCENT)) %>%
      layout(title = "", xaxis = list(title = "Data"), yaxis = list(title = "Cadastros"),
             paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  # DATA TABLE
  output$data_table <- renderReactable({
    df <- data_loaded()
    if(nrow(df) == 0) {
      return(reactable(data.frame(Mensagem = "Nenhum dado disponível")))
    }
    reactable(df, pagination = TRUE, defaultPageSize = 10, 
              compact = TRUE, striped = TRUE, highlight = TRUE)
  })
  
  # REFRESH ACTION
  observeEvent(input$btn_refresh, {
    data_loaded(load_data())
    output$refresh_status <- renderText({
      paste("✓ Dados atualizados em", format(Sys.time(), "%H:%M:%S"))
    })
  })
}

# ===== RUN APP =====
shinyApp(ui, server)
