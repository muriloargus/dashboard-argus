library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(reactable)

DASHBOARD_TITLE <- "USUÁRIOS (SUPABASE)"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Usuários em Tempo Real"
COLOR_PRIMARY <- "#63a3d8"

load_data_supabase <- function() {
  tryCatch({
    # Integração Supabase aqui
    # Por enquanto, dados de exemplo
    data.frame(
      id = 1:45,
      nome = paste0("Usuário_", sprintf("%03d", 1:45)),
      email = paste0("user", sprintf("%03d", 1:45), "@company.com"),
      papel = sample(c("Admin", "Analista", "Gestor", "Visualizador"), 45, replace = TRUE),
      status = sample(c("Ativo", "Inativo"), 45, prob = c(0.85, 0.15), replace = TRUE),
      ultimo_acesso = seq(Sys.Date() - 30, Sys.Date(), length.out = 45),
      data_cadastro = seq(Sys.Date() - 180, Sys.Date() - 30, length.out = 45)
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
          infoBox("Total Usuários", textOutput("total_users"), 
                  icon = icon("users"), color = "blue", width = 3),
          infoBox("Usuários Ativos", textOutput("users_ativos"), 
                  icon = icon("check-circle"), color = "green", width = 3),
          infoBox("Usuários Inativos", textOutput("users_inativos"), 
                  icon = icon("pause-circle"), color = "orange", width = 3),
          infoBox("Taxa Atividade", textOutput("taxa_atividade"), 
                  icon = icon("percent"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_papeis"), width = 6, title = "Distribuição de Papéis"),
          box(plotlyOutput("chart_status"), width = 6, title = "Status dos Usuários")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Usuários Cadastrados por Data")
        )
      ),
      tabItem(tabName = "dados",
        h2("Dados Supabase"),
        reactableOutput("data_table")
      ),
      tabItem(tabName = "refresh",
        h2("Sincronizar Usuários"),
        actionButton("btn_sync", "🔄 Sincronizar", 
                     class = "btn-lg", style = "background-color: #63a3d8; color: white;"),
        textOutput("sync_status")
      )
    )
  )
)

server <- function(input, output, session) {
  data_loaded <- reactiveVal(load_data_supabase())
  
  output$total_users <- renderText({ nrow(data_loaded()) })
  output$users_ativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) == "ativo", na.rm = TRUE) else nrow(df)
  })
  output$users_inativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) == "inativo", na.rm = TRUE) else 0
  })
  output$taxa_atividade <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0%")
    ativos <- if("status" %in% names(df)) sum(tolower(df$status) == "ativo", na.rm = TRUE) else nrow(df)
    paste0(round((ativos / nrow(df)) * 100, 1), "%")
  })
  
  output$chart_papeis <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("papel" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(papel) %>% summarise(Count = n(), .groups = 'drop') %>% arrange(desc(Count))
    plot_ly(counts, x = ~Count, y = ~papel, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), paper_bgcolor = 'rgba(240,244,255,1)',
             plot_bgcolor = 'rgba(240,244,255,1)', showlegend = FALSE)
  })
  
  output$chart_status <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("status" %in% names(df))) return(plotly_empty())
    counts <- df %>% group_by(status) %>% summarise(Count = n(), .groups = 'drop')
    plot_ly(counts, labels = ~status, values = ~Count, type = "pie",
            marker = list(colors = c("#28a745", "#ff6b6b"))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0 || !("data_cadastro" %in% names(df))) return(plotly_empty())
    timeline <- df %>%
      group_by(data_cadastro) %>%
      summarise(Count = n(), .groups = 'drop') %>%
      arrange(data_cadastro)
    plot_ly(timeline, x = ~data_cadastro, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = "#FFD700")) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Novos Usuários"),
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
