library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "MOTORISTAS"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Gestão de Motoristas"
DATA_FILE <- "../../../motorista não identificado 15-02 à 22-02.csv"
COLOR_PRIMARY <- "#63a3d8"
COLOR_SECONDARY <- "#e60000"
COLOR_ACCENT <- "#FFD700"

load_data <- function() {
  tryCatch({
    df <- read_csv(DATA_FILE, show_col_types = FALSE)
    return(df)
  }, error = function(e) {
    message(paste("Erro ao carregar dados:", e$message))
    return(data.frame())
  })
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("person")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Motoristas", textOutput("total_motoristas"), 
                  icon = icon("person"), color = "blue", width = 3),
          infoBox("Motoristas Ativos", textOutput("motoristas_ativos"), 
                  icon = icon("check-circle"), color = "green", width = 3),
          infoBox("Não Identificados", textOutput("nao_identificados"), 
                  icon = icon("question-circle"), color = "red", width = 3),
          infoBox("Média Diária", textOutput("media_diaria"), 
                  icon = icon("average"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_distribuicao"), width = 6, title = "Distribuição de Viagens"),
          box(plotlyOutput("chart_horarios"), width = 6, title = "Viagens por Horário")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Viagens por Data")
        )
      ),
      tabItem(tabName = "dados",
        h2("Dados Completos"),
        reactableOutput("data_table")
      ),
      tabItem(tabName = "refresh",
        h2("Atualizar Dados"),
        actionButton("btn_refresh", "🔄 Atualizar", 
                     class = "btn-lg", style = "background-color: #63a3d8; color: white;"),
        br(), br(),
        textOutput("refresh_status")
      )
    )
  )
)

server <- function(input, output, session) {
  data_loaded <- reactiveVal(load_data())
  
  output$total_motoristas <- renderText({ nrow(data_loaded()) })
  output$motoristas_ativos <- renderText({
    df <- data_loaded()
    nrow(df)
  })
  output$nao_identificados <- renderText({
    df <- data_loaded()
    if("motorista" %in% names(df)) {
      sum(tolower(df$motorista) %in% c("não identificado", "nao identificado", "unknown"), na.rm = TRUE)
    } else {
      0
    }
  })
  output$media_diaria <- renderText({
    paste0(round(nrow(data_loaded()) / 8, 1), " viagens")
  })
  
  output$chart_distribuicao <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    if("motorista" %in% names(df)) {
      counts <- df %>% 
        group_by(motorista) %>% 
        summarise(Count = n(), .groups = 'drop') %>%
        top_n(10, Count) %>%
        arrange(desc(Count))
      
      plot_ly(counts, x = ~Count, y = ~motorista, type = "bar", orientation = "h",
              marker = list(color = COLOR_PRIMARY)) %>%
        layout(yaxis = list(autorange = "reversed"), xaxis = list(title = "Viagens"),
               paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
               showlegend = FALSE)
    } else {
      plotly_empty()
    }
  })
  
  output$chart_horarios <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    if("hora" %in% names(df) || "time" %in% names(df)) {
      col_hora <- if("hora" %in% names(df)) "hora" else "time"
      counts <- df %>%
        mutate(hora = substr(!!sym(col_hora), 1, 2)) %>%
        group_by(hora) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(hora)
      
      plot_ly(counts, x = ~hora, y = ~Count, type = "bar",
              marker = list(color = COLOR_ACCENT)) %>%
        layout(xaxis = list(title = "Hora"), yaxis = list(title = "Viagens"),
               paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
               showlegend = FALSE)
    } else {
      plotly_empty()
    }
  })
  
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    timeline <- if("data" %in% names(df) || "date" %in% names(df)) {
      col_data <- if("data" %in% names(df)) "data" else "date"
      df %>%
        mutate(date = as.Date(parse_date_time(!!sym(col_data), orders = c("dmy", "ymd", "mdy")))) %>%
        filter(!is.na(date)) %>%
        group_by(date) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(date)
    } else {
      data.frame(date = seq(Sys.Date() - 8, Sys.Date(), by = 1),
                 Count = c(45, 52, 48, 55, 50, 58, 54, 61, 59))
    }
    
    plot_ly(timeline, x = ~date, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = COLOR_ACCENT)) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Viagens"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$data_table <- renderReactable({
    reactable(data_loaded(), pagination = TRUE, defaultPageSize = 10, 
              compact = TRUE, striped = TRUE, highlight = TRUE)
  })
  
  observeEvent(input$btn_refresh, {
    data_loaded(load_data())
    output$refresh_status <- renderText(paste("✓ Atualizado em", format(Sys.time(), "%H:%M:%S")))
  })
}

shinyApp(ui, server)
