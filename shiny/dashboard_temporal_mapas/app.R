library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "TEMPORAL MAPS"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Análise Temporal Geográfica"
COLOR_PRIMARY <- "#63a3d8"

load_data <- function() {
  data.frame(
    hora = sprintf("%02d:00", 0:23),
    viagens = sample(5:25, 24, replace = TRUE),
    localizacoes = sample(10:50, 24, replace = TRUE),
    velocidade_media = sample(30:80, 24, replace = TRUE)
  )
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("map")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total Viagens 24h", textOutput("total_viagens"), 
                  icon = icon("route"), color = "blue", width = 3),
          infoBox("Localizações Únicas", textOutput("total_locs"), 
                  icon = icon("map-marker"), color = "red", width = 3),
          infoBox("Velocidade Média", textOutput("vel_media"), 
                  icon = icon("tachometer-alt"), color = "green", width = 3),
          infoBox("Pico Horário", textOutput("pico_horario"), 
                  icon = icon("clock"), color = "orange", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_viagens_por_hora"), width = 12, title = "Viagens por Hora do Dia")
        ),
        fluidRow(
          box(plotlyOutput("chart_velocidade"), width = 6, title = "Velocidade por Hora"),
          box(plotlyOutput("chart_localizacoes"), width = 6, title = "Localizações Únicas por Hora")
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
  output$total_locs <- renderText({
    sum(data_loaded()$localizacoes)
  })
  output$vel_media <- renderText({
    paste0(round(mean(data_loaded()$velocidade_media), 1), " km/h")
  })
  output$pico_horario <- renderText({
    df <- data_loaded()
    max_hora <- df$hora[which.max(df$viagens)]
    paste0(max_hora, "h")
  })
  
  output$chart_viagens_por_hora <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~hora, y = ~viagens, type = "bar",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(xaxis = list(title = "Hora do Dia"), yaxis = list(title = "Viagens"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$chart_velocidade <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~hora, y = ~velocidade_media, type = "scatter", mode = "lines+markers",
            line = list(color = "#28a745", width = 2),
            marker = list(size = 6, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Hora do Dia"), yaxis = list(title = "Velocidade (km/h)"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$chart_localizacoes <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~hora, y = ~localizacoes, type = "scatter", mode = "lines+markers",
            line = list(color = "#e60000", width = 2),
            marker = list(size = 6, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Hora do Dia"), yaxis = list(title = "Localizações"),
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
