library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(reactable)

DASHBOARD_TITLE <- "ATIVOS (SUPABASE)"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Ativos em Tempo Real"
COLOR_PRIMARY <- "#63a3d8"
COLOR_ACCENT <- "#FFD700"

# Função para conectar ao Supabase
load_data_supabase <- function() {
  tryCatch({
    # Substitua com suas credenciais Supabase
    # library(RPostgres)
    # con <- dbConnect(
    #   Postgres(),
    #   host = Sys.getenv("SUPABASE_HOST"),
    #   dbname = Sys.getenv("SUPABASE_DB"),
    #   user = Sys.getenv("SUPABASE_USER"),
    #   password = Sys.getenv("SUPABASE_PASSWORD"),
    #   port = 5432
    # )
    # df <- dbGetQuery(con, "SELECT * FROM ativos LIMIT 1000")
    # dbDisconnect(con)
    
    # Por enquanto, dados de exemplo
    data.frame(
      id = 1:50,
      placa = paste0("ABC-", sprintf("%04d", 1:50)),
      status = sample(c("Ativo", "Inativo"), 50, replace = TRUE),
      tipo = sample(c("Caminhão", "Van", "Carro"), 50, replace = TRUE),
      data_cadastro = seq(Sys.Date() - 365, Sys.Date(), length.out = 50),
      ultima_localizacao = sample(c("São Paulo", "Rio de Janeiro", "Belo Horizonte", "Salvador"), 50, replace = TRUE)
    )
  }, error = function(e) {
    message(paste("Erro ao conectar Supabase:", e$message))
    data.frame()
  })
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("cloud")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total (Supabase)", textOutput("total_ativos"), 
                  icon = icon("database"), color = "blue", width = 3),
          infoBox("Ativos", textOutput("ativos_ativos"), 
                  icon = icon("check-circle"), color = "green", width = 3),
          infoBox("Inativos", textOutput("ativos_inativos"), 
                  icon = icon("pause-circle"), color = "orange", width = 3),
          infoBox("Taxa Utilização", textOutput("taxa_utilizacao"), 
                  icon = icon("percent"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_status"), width = 6, title = "Status dos Ativos"),
          box(plotlyOutput("chart_tipos"), width = 6, title = "Distribuição Tipos")
        ),
        fluidRow(
          box(plotlyOutput("chart_localizacoes"), width = 12, title = "Ativos por Localização")
        )
      ),
      tabItem(tabName = "dados",
        h2("Dados do Supabase"),
        reactableOutput("data_table")
      ),
      tabItem(tabName = "refresh",
        h2("Sincronizar com Supabase"),
        p("Última sincronização: ", textOutput("last_sync", inline = TRUE)),
        br(),
        actionButton("btn_sync", "🔄 Sincronizar Agora", 
                     class = "btn-lg", style = "background-color: #63a3d8; color: white;"),
        textOutput("sync_status")
      )
    )
  )
)

server <- function(input, output, session) {
  data_loaded <- reactiveVal(load_data_supabase())
  
  output$total_ativos <- renderText({ nrow(data_loaded()) })
  output$ativos_ativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) == "ativo", na.rm = TRUE) else nrow(df)
  })
  output$ativos_inativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) == "inativo", na.rm = TRUE) else 0
  })
  output$taxa_utilizacao <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0%")
    ativos <- if("status" %in% names(df)) sum(tolower(df$status) == "ativo", na.rm = TRUE) else nrow(df)
    paste0(round((ativos / nrow(df)) * 100, 1), "%")
  })
  output$last_sync <- renderText({
    format(Sys.time(), "%d/%m/%Y %H:%M")
  })
  
  output$chart_status <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("status" %in% names(df)) {
      df %>% group_by(status) %>% summarise(Count = n(), .groups = 'drop')
    } else {
      data.frame(status = "Desconhecido", Count = nrow(df))
    }
    plot_ly(counts, labels = ~status, values = ~Count, type = "pie",
            marker = list(colors = c(COLOR_ACCENT, "#ff6b6b"))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_tipos <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("tipo" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(tipo) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count))
    plot_ly(counts, x = ~Count, y = ~tipo, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)', showlegend = FALSE)
  })
  
  output$chart_localizacoes <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("ultima_localizacao" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(ultima_localizacao) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count))
    plot_ly(counts, x = ~ultima_localizacao, y = ~Count, type = "bar",
            marker = list(color = COLOR_ACCENT)) %>%
      layout(xaxis = list(title = "Localização"), yaxis = list(title = "Quantidade"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$data_table <- renderReactable({
    reactable(data_loaded(), pagination = TRUE, defaultPageSize = 10, 
              compact = TRUE, striped = TRUE, highlight = TRUE)
  })
  
  observeEvent(input$btn_sync, {
    data_loaded(load_data_supabase())
    output$sync_status <- renderText({
      h4(style = "color: #28a745;", "✓ Sincronização completa!")
    })
  })
}

shinyApp(ui, server)
