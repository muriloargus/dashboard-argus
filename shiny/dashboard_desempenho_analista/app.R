library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "DESEMPENHO ANALISTA"
DASHBOARD_SUBTITLE <- "Telemetria CCO - KPI dos Analistas"
COLOR_PRIMARY <- "#63a3d8"

load_data <- function() {
  data.frame(
    analista = c("Ana Silva", "Bruno Costa", "Carlos Santos", "Diana Lima", 
                 "Eduardo Rocha", "Fernanda Costa", "Gabriel Alves", "Helena Sousa"),
    tickets_resolvidos = sample(15:50, 8),
    tempo_medio_hrs = round(sample(1:8, 8), 1),
    taxa_satisfacao = sample(85:99, 8),
    escalacoes = sample(0:5, 8),
    produtividade_pct = sample(75:105, 8)
  )
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-bar")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total Tickets Resolvidos", textOutput("total_tickets"), 
                  icon = icon("check"), color = "blue", width = 3),
          infoBox("Tempo Médio Resolução", textOutput("tempo_medio"), 
                  icon = icon("clock"), color = "green", width = 3),
          infoBox("Satisfação Média", textOutput("satisfacao_media"), 
                  icon = icon("star"), color = "orange", width = 3),
          infoBox("Produtividade Média", textOutput("produtividade_media"), 
                  icon = icon("tachometer-alt"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_analistas"), width = 12, title = "Tickets Resolvidos por Analista")
        ),
        fluidRow(
          box(plotlyOutput("chart_satisfacao"), width = 6, title = "Taxa de Satisfação"),
          box(plotlyOutput("chart_produtividade"), width = 6, title = "Produtividade (%)")
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
  
  output$total_tickets <- renderText({
    sum(data_loaded()$tickets_resolvidos)
  })
  output$tempo_medio <- renderText({
    paste0(round(mean(data_loaded()$tempo_medio_hrs), 1), " hrs")
  })
  output$satisfacao_media <- renderText({
    paste0(round(mean(data_loaded()$taxa_satisfacao), 1), "%")
  })
  output$produtividade_media <- renderText({
    paste0(round(mean(data_loaded()$produtividade_pct), 1), "%")
  })
  
  output$chart_analistas <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~analista, y = ~tickets_resolvidos, type = "bar",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(xaxis = list(title = "Analista"), yaxis = list(title = "Tickets Resolvidos"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$chart_satisfacao <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~analista, y = ~taxa_satisfacao, type = "bar",
            marker = list(color = "#FFD700")) %>%
      layout(xaxis = list(title = "Analista"), yaxis = list(title = "Satisfação (%)"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$chart_produtividade <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~analista, y = ~produtividade_pct, type = "scatter", mode = "lines+markers",
            line = list(color = "#28a745", width = 2),
            marker = list(size = 8, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Analista"), yaxis = list(title = "Produtividade (%)"),
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
