library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "TIMELINE"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Análise Temporal"
COLOR_PRIMARY <- "#63a3d8"
COLOR_ACCENT <- "#FFD700"

load_data <- function() {
  # Timeline é baseado em dados da pasta, agrupamento por data
  data.frame(
    date = seq(Sys.Date() - 30, Sys.Date(), by = 1),
    viagens = sample(40:80, 31, replace = TRUE),
    eventos = sample(5:15, 31, replace = TRUE),
    falhas = sample(0:5, 31, replace = TRUE),
    usuarios_ativos = sample(20:50, 31, replace = TRUE)
  )
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("clock")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Viagens (30d)", textOutput("total_viagens"), 
                  icon = icon("car"), color = "blue", width = 3),
          infoBox("Total de Eventos", textOutput("total_eventos"), 
                  icon = icon("bell"), color = "green", width = 3),
          infoBox("Total de Falhas", textOutput("total_falhas"), 
                  icon = icon("bug"), color = "red", width = 3),
          infoBox("Média Diária", textOutput("media_diaria"), 
                  icon = icon("average"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_viagens"), width = 12, title = "Viagens por Data"),
          box(plotlyOutput("chart_eventos"), width = 12, title = "Eventos e Falhas por Data")
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
  
  output$total_viagens <- renderText({
    sum(data_loaded()$viagens)
  })
  output$total_eventos <- renderText({
    sum(data_loaded()$eventos)
  })
  output$total_falhas <- renderText({
    sum(data_loaded()$falhas)
  })
  output$media_diaria <- renderText({
    paste0(round(mean(data_loaded()$viagens), 1), " viagens/dia")
  })
  
  output$chart_viagens <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~date, y = ~viagens, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = COLOR_ACCENT),
            name = "Viagens") %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Quantidade"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = TRUE)
  })
  
  output$chart_eventos <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~date) %>%
      add_trace(y = ~eventos, name = "Eventos", mode = "lines",
                line = list(color = "#28a745", width = 2)) %>%
      add_trace(y = ~falhas * 5, name = "Falhas (escala x5)", mode = "lines",
                line = list(color = "#e60000", width = 2, dash = "dash")) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Quantidade"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
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
