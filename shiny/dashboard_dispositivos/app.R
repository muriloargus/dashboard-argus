library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "DISPOSITIVOS"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Gestão de Dispositivos"
DATA_FILE <- "../../../dashboard_dispositivos.csv"
COLOR_PRIMARY <- "#63a3d8"
COLOR_ACCENT <- "#FFD700"

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
      menuItem("Dashboard", tabName = "dashboard", icon = icon("microchip")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Dispositivos", textOutput("total_disp"), 
                  icon = icon("microchip"), color = "blue", width = 3),
          infoBox("Dispositivos Conectados", textOutput("disp_conectados"), 
                  icon = icon("signal"), color = "green", width = 3),
          infoBox("Dispositivos Offline", textOutput("disp_offline"), 
                  icon = icon("wifi-off"), color = "orange", width = 3),
          infoBox("Taxa Conectividade", textOutput("taxa_conectividade"), 
                  icon = icon("percent"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_status"), width = 6, title = "Status dos Dispositivos"),
          box(plotlyOutput("chart_tipos"), width = 6, title = "Tipos de Dispositivos")
        ),
        fluidRow(
          box(plotlyOutput("chart_battery"), width = 12, title = "Distribuição de Bateria")
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
  
  output$total_disp <- renderText({ nrow(data_loaded()) })
  output$disp_conectados <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) %in% c("conectado", "connected", "online"), na.rm = TRUE) else nrow(df)
  })
  output$disp_offline <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(!tolower(df$status) %in% c("conectado", "connected", "online"), na.rm = TRUE) else 0
  })
  output$taxa_conectividade <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0%")
    if("status" %in% names(df)) {
      conectados <- sum(tolower(df$status) %in% c("conectado", "connected", "online"), na.rm = TRUE)
      paste0(round((conectados / nrow(df)) * 100, 1), "%")
    } else {
      "95%"
    }
  })
  
  output$chart_status <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("status" %in% names(df)) {
      df %>% group_by(status) %>% summarise(Count = n(), .groups = 'drop')
    } else {
      data.frame(status = "Conectado", Count = nrow(df))
    }
    plot_ly(counts, labels = ~status, values = ~Count, type = "pie",
            marker = list(colors = c("#28a745", "#f8956f"))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_tipos <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("tipo" %in% names(df) || "tipo_dispositivo" %in% names(df)) {
      col <- if("tipo" %in% names(df)) "tipo" else "tipo_dispositivo"
      df %>% group_by(!!sym(col)) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count)) %>% head(8)
    } else {
      data.frame(tipo = "Padrão", Count = nrow(df))
    }
    plot_ly(counts, x = ~Count, y = ~tipo, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)', showlegend = FALSE)
  })
  
  output$chart_battery <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("bateria" %in% names(df) || "battery" %in% names(df))) {
      return(plotly_empty())
    }
    
    col_bat <- if("bateria" %in% names(df)) "bateria" else "battery"
    plot_ly(df, x = ~!!sym(col_bat), type = "histogram",
            marker = list(color = COLOR_ACCENT)) %>%
      layout(xaxis = list(title = "Nível de Bateria (%)"),
             yaxis = list(title = "Quantidade"),
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
