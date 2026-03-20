library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(reactable)

DASHBOARD_TITLE <- "FALHAS (SUPABASE)"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Falhas em Tempo Real"
COLOR_PRIMARY <- "#e60000"

load_data_supabase <- function() {
  tryCatch({
    # Integração Supabase aqui
    # Por enquanto, dados de exemplo
    data.frame(
      id = 1:35,
      dispositivo = paste0("DEV-", sprintf("%04d", 1:35)),
      tipo_falha = sample(c("Sensor", "Conexão", "Bateria", "Drivers", "Software"), 35, replace = TRUE),
      severidade = sample(c("Crítica", "Alta", "Média"), 35, prob = c(0.15, 0.35, 0.5), replace = TRUE),
      status = sample(c("Aberta", "Resolvida", "Pausada"), 35, replace = TRUE),
      data_registro = seq(Sys.Date() - 20, Sys.Date(), length.out = 35),
      tempo_resolucao_hrs = sample(1:48, 35)
    )
  }, error = function(e) {
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
          infoBox("Total Falhas", textOutput("total_falhas"), 
                  icon = icon("bug"), color = "red", width = 3),
          infoBox("Falhas Críticas", textOutput("falhas_criticas"), 
                  icon = icon("exclamation"), color = "red", width = 3),
          infoBox("Resolvidas", textOutput("falhas_resolvidas"), 
                  icon = icon("check"), color = "green", width = 3),
          infoBox("Tempo Med. Resolução", textOutput("tempo_medio"), 
                  icon = icon("clock"), color = "blue", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_severidade"), width = 6, title = "Severidade das Falhas"),
          box(plotlyOutput("chart_tipos_falha"), width = 6, title = "Tipos de Falha")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Falhas por Data")
        )
      ),
      tabItem(tabName = "dados",
        h2("Dados Supabase"),
        reactableOutput("data_table")
      ),
      tabItem(tabName = "refresh",
        h2("Sincronizar Falhas"),
        actionButton("btn_sync", "🔄 Sincronizar", 
                     class = "btn-lg", style = "background-color: #e60000; color: white;"),
        textOutput("sync_status")
      )
    )
  )
)

server <- function(input, output, session) {
  data_loaded <- reactiveVal(load_data_supabase())
  
  output$total_falhas <- renderText({ nrow(data_loaded()) })
  output$falhas_criticas <- renderText({
    df <- data_loaded()
    if("severidade" %in% names(df)) sum(tolower(df$severidade) == "crítica", na.rm = TRUE) else 0
  })
  output$falhas_resolvidas <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) == "resolvida", na.rm = TRUE) else 0
  })
  output$tempo_medio <- renderText({
    df <- data_loaded()
    if("tempo_resolucao_hrs" %in% names(df)) {
      paste0(round(mean(df$tempo_resolucao_hrs, na.rm = TRUE), 1), " hrs")
    } else {
      "N/A"
    }
  })
  
  output$chart_severidade <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("severidade" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(severidade) %>% summarise(Count = n(), .groups = 'drop')
    plot_ly(counts, labels = ~severidade, values = ~Count, type = "pie",
            marker = list(colors = c("#e60000", "#ff9800", "#FFD700"))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_tipos_falha <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("tipo_falha" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(tipo_falha) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count))
    plot_ly(counts, x = ~Count, y = ~tipo_falha, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)', showlegend = FALSE)
  })
  
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("data_registro" %in% names(df))) return(plotly_empty())
    timeline <- df %>%
      group_by(data_registro) %>%
      summarise(Count = n(), .groups = 'drop') %>%
      arrange(data_registro)
    plot_ly(timeline, x = ~data_registro, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Falhas"),
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
      h4(style = "color: #28a745;", "✓ Sincronizado!")
    })
  })
}

shinyApp(ui, server)
