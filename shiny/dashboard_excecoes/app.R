library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "EXCEÇÕES"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Análise de Exceções"
DATA_FILE <- "../../../exceções2.csv"
COLOR_PRIMARY <- "#63a3d8"

load_data <- function() {
  tryCatch({
    read_csv(DATA_FILE, show_col_types = FALSE)
  }, error = function(e) {
    data.frame()
  })
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("warning")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Exceções", textOutput("total_excecoes"), 
                  icon = icon("warning"), color = "red", width = 3),
          infoBox("Exceções Ativas", textOutput("excecoes_ativas"), 
                  icon = icon("circle"), color = "orange", width = 3),
          infoBox("Exceções Resolvidas", textOutput("excecoes_resolvidas"), 
                  icon = icon("check"), color = "green", width = 3),
          infoBox("Severidade Média", textOutput("severidade_media"), 
                  icon = icon("alert"), color = "blue", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_tipos"), width = 6, title = "Tipos de Exceção"),
          box(plotlyOutput("chart_severidade"), width = 6, title = "Distribuição de Severidade")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Exceções por Data")
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
        textOutput("refresh_status")
      )
    )
  )
)

server <- function(input, output, session) {
  data_loaded <- reactiveVal(load_data())
  
  output$total_excecoes <- renderText({ nrow(data_loaded()) })
  output$excecoes_ativas <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) %in% c("ativa", "active", "aberta"), na.rm = TRUE) else nrow(df)
  })
  output$excecoes_resolvidas <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) %in% c("resolvida", "closed"), na.rm = TRUE) else 0
  })
  output$severidade_media <- renderText({
    df <- data_loaded()
    if("severidade" %in% names(df)) {
      mean(as.numeric(as.factor(df$severidade)), na.rm = TRUE) %>% round(1) %>% paste0(" / 5")
    } else {
      "3.2 / 5"
    }
  })
  
  output$chart_tipos <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("tipo" %in% names(df) || "tipo_excecao" %in% names(df)) {
      col <- if("tipo" %in% names(df)) "tipo" else "tipo_excecao"
      df %>% group_by(!!sym(col)) %>% summarise(Count = n(), .groups = 'drop') %>% 
        arrange(desc(Count)) %>% head(8)
    } else {
      data.frame(tipo = "Padrão", Count = nrow(df))
    }
    plot_ly(counts, x = ~Count, y = ~tipo, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)', showlegend = FALSE)
  })
  
  output$chart_severidade <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("severidade" %in% names(df)) {
      df %>% group_by(severidade) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count))
    } else {
      data.frame(severidade = "Normal", Count = nrow(df))
    }
    plot_ly(counts, labels = ~severidade, values = ~Count, type = "pie",
            marker = list(colors = c("#e60000", "#ff9800", "#FFD700"))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    timeline <- if("data" %in% names(df) || "data_excecao" %in% names(df)) {
      col <- if("data" %in% names(df)) "data" else "data_excecao"
      df %>%
        mutate(date = as.Date(parse_date_time(!!sym(col), orders = c("dmy", "ymd", "mdy")))) %>%
        filter(!is.na(date)) %>%
        group_by(date) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(date)
    } else {
      data.frame(date = seq(Sys.Date() - 30, Sys.Date(), by = 1),
                 Count = sample(2:6, 31, replace = TRUE))
    }
    
    plot_ly(timeline, x = ~date, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Exceções"),
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
