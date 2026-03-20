library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(reactable)

DASHBOARD_TITLE <- "USUÁRIOS"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Gestão de Usuários"
DATA_FILE <- "../../../dashboard_usuarios.csv"
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
      menuItem("Dashboard", tabName = "dashboard", icon = icon("users")),
      menuItem("Dados", tabName = "dados", icon = icon("table")),
      menuItem("Atualizar", tabName = "refresh", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          infoBox("Total de Usuários", textOutput("total_users"), 
                  icon = icon("users"), color = "blue", width = 3),
          infoBox("Usuários Ativos", textOutput("users_ativos"), 
                  icon = icon("check-circle"), color = "green", width = 3),
          infoBox("Usuários Inativos", textOutput("users_inativos"), 
                  icon = icon("pause-circle"), color = "orange", width = 3),
          infoBox("Taxa de Atividade", textOutput("taxa_atividade"), 
                  icon = icon("percent"), color = "purple", width = 3)
        ),
        fluidRow(
          box(plotlyOutput("chart_status"), width = 6, title = "Status dos Usuários"),
          box(plotlyOutput("chart_roles"), width = 6, title = "Distribuição por Papel")
        ),
        fluidRow(
          box(plotlyOutput("chart_timeline"), width = 12, title = "Usuários Cadastrados por Data")
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
  
  output$total_users <- renderText({ nrow(data_loaded()) })
  output$users_ativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(tolower(df$status) %in% c("ativo", "active"), na.rm = TRUE) else nrow(df)
  })
  output$users_inativos <- renderText({
    df <- data_loaded()
    if("status" %in% names(df)) sum(!tolower(df$status) %in% c("ativo", "active"), na.rm = TRUE) else 0
  })
  output$taxa_atividade <- renderText({
    df <- data_loaded()
    if(nrow(df) == 0) return("0%")
    ativos <- if("status" %in% names(df)) sum(tolower(df$status) %in% c("ativo", "active"), na.rm = TRUE) else nrow(df)
    paste0(round((ativos / nrow(df)) * 100, 1), "%")
  })
  
  output$chart_status <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("status" %in% names(df)) {
      df %>% group_by(status) %>% summarise(Count = n(), .groups = 'drop')
    } else {
      data.frame(status = "Ativo", Count = nrow(df))
    }
    plot_ly(counts, labels = ~status, values = ~Count, type = "pie",
            marker = list(colors = c(COLOR_ACCENT, COLOR_SECONDARY))) %>%
      layout(paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)')
  })
  
  output$chart_roles <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    counts <- if("role" %in% names(df) || "perfil" %in% names(df)) {
      col_role <- if("role" %in% names(df)) "role" else "perfil"
      df %>% group_by(!!sym(col_role)) %>% summarise(Count = n(), .groups = 'drop') %>%
        arrange(desc(Count)) %>% head(8)
    } else {
      data.frame(role = "Padrão", Count = nrow(df))
    }
    plot_ly(counts, x = ~Count, y = ~role, type = "bar", orientation = "h",
            marker = list(color = COLOR_PRIMARY)) %>%
      layout(yaxis = list(autorange = "reversed"), xaxis = list(title = "Quantidade"),
             paper_bgcolor = 'rgba(240,244,255,1)', plot_bgcolor = 'rgba(240,244,255,1)',
             showlegend = FALSE)
  })
  
  output$chart_timeline <- renderPlotly({
    df <- data_loaded()
    if(nrow(df) == 0) return(plotly_empty())
    
    timeline <- if("data_cadastro" %in% names(df) || "created_at" %in% names(df)) {
      col_data <- if("data_cadastro" %in% names(df)) "data_cadastro" else "created_at"
      df %>%
        mutate(date = as.Date(parse_date_time(!!sym(col_data), orders = c("ymd", "dmy", "mdy")))) %>%
        filter(!is.na(date)) %>%
        group_by(date) %>%
        summarise(Count = n(), .groups = 'drop') %>%
        arrange(date)
    } else {
      data.frame(date = seq(Sys.Date() - 30, Sys.Date(), by = 1),
                 Count = sample(1:3, 31, replace = TRUE))
    }
    
    plot_ly(timeline, x = ~date, y = ~Count, type = "scatter", mode = "lines+markers",
            line = list(color = COLOR_PRIMARY, width = 3),
            marker = list(size = 8, color = COLOR_ACCENT)) %>%
      layout(xaxis = list(title = "Data"), yaxis = list(title = "Novos Usuários"),
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
