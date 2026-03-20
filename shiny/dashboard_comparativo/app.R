library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "COMPARATIVO"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Análise Comparativa"
COLOR_PRIMARY <- "#63a3d8"

load_data <- function() {
  data.frame(
    metricas = c("Viagens", "Usuários", "Dispositivos", "Falhas", "Exceções", "Eventos"),
    janeiro = sample(100:500, 6),
    fevereiro = sample(100:500, 6),
    marco = sample(100:500, 6)
  )
}

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Variação Viagens", textOutput("var_viagens"), 
                  icon = icon("chart-line"), color = "blue", width = 3),
          infoBox("Variação Usuários", textOutput("var_usuarios"), 
                  icon = icon("users"), color = "green", width = 3),
          infoBox("Variação Dispositivos", textOutput("var_dispositivos"), 
                  icon = icon("microchip"), color = "orange", width = 3),
          infoBox("Variação Falhas", textOutput("var_falhas"), 
                  icon = icon("bug"), color = "red", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_comparativo"), width = 12, title = "Comparativo de Métricas por Mês")
        ),
        fluidRow(
          box(plotlyOutput("chart_tendencia"), width = 12, title = "Tendência Geral")
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
  
  output$var_viagens <- renderText({
    df <- data_loaded()
    var <- ((df$marco[1] - df$janeiro[1]) / df$janeiro[1] * 100) %>% round(1)
    paste0(if(var >= 0) "+" else "", var, "%")
  })
  
  output$var_usuarios <- renderText({
    df <- data_loaded()
    var <- ((df$marco[2] - df$janeiro[2]) / df$janeiro[2] * 100) %>% round(1)
    paste0(if(var >= 0) "+" else "", var, "%")
  })
  
  output$var_dispositivos <- renderText({
    df <- data_loaded()
    var <- ((df$marco[3] - df$janeiro[3]) / df$janeiro[3] * 100) %>% round(1)
    paste0(if(var >= 0) "+" else "", var, "%")
  })
  
  output$var_falhas <- renderText({
    df <- data_loaded()
    var <- ((df$marco[5] - df$janeiro[5]) / df$janeiro[5] * 100) %>% round(1)
    paste0(if(var >= 0) "+" else "", var, "%")
  })
  
  output$chart_comparativo <- renderPlotly({
    df <- data_loaded()
    plot_ly(df, x = ~metricas) %>%
      add_trace(y = ~janeiro, name = "Janeiro", type = "bar") %>%
      add_trace(y = ~fevereiro, name = "Fevereiro", type = "bar") %>%
      add_trace(y = ~marco, name = "Março", type = "bar") %>%
      layout(barmode = "group",
             xaxis = list(title = "Métricas"),
             yaxis = list(title = "Valores"),
             paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_tendencia <- renderPlotly({
    df <- data_loaded()
    df_trend <- data.frame(
      mes = c("Janeiro", "Fevereiro", "Março"),
      viagens = c(mean(df$janeiro[1]), mean(df$fevereiro[1]), mean(df$marco[1])),
      usuarios = c(mean(df$janeiro[2]), mean(df$fevereiro[2]), mean(df$marco[2])),
      falhas = c(mean(df$janeiro[5]), mean(df$fevereiro[5]), mean(df$marco[5]))
    )
    
    plot_ly(df_trend, x = ~mes) %>%
      add_trace(y = ~viagens, name = "Viagens", type = "scatter", mode = "lines+markers") %>%
      add_trace(y = ~usuarios, name = "Usuários", type = "scatter", mode = "lines+markers") %>%
      add_trace(y = ~falhas, name = "Falhas", type = "scatter", mode = "lines+markers") %>%
      layout(xaxis = list(title = "Mês"),
             yaxis = list(title = "Valores"),
             paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)')
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
