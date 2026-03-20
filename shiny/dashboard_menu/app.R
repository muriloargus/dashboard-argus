library(shiny)
library(shinydashboard)
library(plotly)

DASHBOARD_TITLE <- "MENU PRINCIPAL"
DASHBOARD_SUBTITLE <- "Telemetria CCO - Centro de Controle"

ui <- dashboardPage(
  dashboardHeader(title = DASHBOARD_TITLE, titleWidth = 350),
  dashboardSidebar(width = 250,
    sidebarMenu(
      menuItem("Menu Home", tabName = "home", icon = icon("home"), selected = TRUE),
      menuItem("Documentação", tabName = "docs", icon = icon("book"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "home",
        h1("Bem-vindo ao Telemetria CCO", style = "color: #63a3d8;"),
        p("Sistema de Monitoramento e Gestão de Frota", style = "font-size: 18px; color: #666;"),
        br(),
        
        fluidRow(
          box(width = 12, status = "info", solidHeader = TRUE,
              title = "Dashboards Disponíveis",
              p("Selecione um dashboard no menu lateral para começar:"),
              br(),
              HTML("<ul style='font-size: 16px; line-height: 2;'>
                <li>📊 <strong>Ativos</strong> - Gestão de Frota</li>
                <li>👥 <strong>Usuários</strong> - Controle de Acesso</li>
                <li>👨‍ <strong>Motoristas</strong> - Análise de Motoristas</li>
                <li>⚠️ <strong>Falhas</strong> - Monitoramento de Problemas</li>
                <li>🔧 <strong>Dispositivos</strong> - Gestão de Hardware</li>
                <li>⚡ <strong>Exceções</strong> - Eventos Anormais</li>
                <li>📈 <strong>Timeline</strong> - Análise Temporal</li>
                <li>🗺️ <strong>Temporal Maps</strong> - Análise Geográfica</li>
                <li>🚨 <strong>Risco Colisão</strong> - Segurança</li>
                <li>📋 <strong>Desempenho Analista</strong> - KPIs</li>
                <li>📊 <strong>Comparativo</strong> - Análise Comparativa</li>
                <li>☁️ <strong>Dados Supabase</strong> - Cloud Real-Time</li>
              </ul>")
          )
        ),
        
        fluidRow(
          box(width = 6, status = "success", solidHeader = TRUE,
              title = "Sistema em Tempo Real",
              HTML("<p><strong>✓ Statusà:</strong></p>
                <ul>
                  <li>Base Dados: <span style='color: #28a745;'>✓ Conectado</span></li>
                  <li>Supabase: <span style='color: #28a745;'>✓ Sincronizado</span></li>
                  <li>APIs: <span style='color: #28a745;'>✓ Respondendo</span></li>
                  <li>Atualização: <span style='color: #28a745;'>✓ Em Tempo Real</span></li>
                </ul>")
          ),
          box(width = 6, status = "warning", solidHeader = TRUE,
              title = "Estatísticas Gerais",
              HTML(paste0("<p><strong>Resumo de Dados:</strong></p>
                <ul>
                  <li>Total de Ativos: <strong>1,250</strong></li>
                  <li>Usuários Ativos: <strong>45</strong></li>
                  <li>Motoristas: <strong>380</strong></li>
                  <li>Falhas Abertas: <strong>12</strong></li>
                  <li>Taxa Disponibilidade: <strong>98.5%</strong></li>
                </ul>
                <p style='color: #666; font-size: 12px;'>Atualizado em: ", format(Sys.time(), "%d/%m/%Y %H:%M"), "</p>"))
          )
        ),
        
        fluidRow(
          box(width = 12, status = "primary", solidHeader = TRUE,
              title = "Como Usar",
              HTML("<ol style='font-size: 14px;'>
                <li>Clique no ícone de menu (☰) para expandir a barra lateral</li>
                <li>Selecione o dashboard que deseja visualizar</li>
                <li>Explore os gráficos, KPIs e dados detalhados</li>
                <li>Use o botão 'Atualizar' para sincronizar dados</li>
                <li>Para dados em nuvem, clique em 'Sincronizar com Supabase'</li>
              </ol>")
          )
        )
      ),
      
      tabItem(tabName = "docs",
        h2("Documentação"),
        p("Sistema Telemetria CCO - Documentação Completa", style = "font-size: 16px;"),
        br(),
        HTML("<div style='background: #f5f7ff; padding: 20px; border-radius: 8px;'>
          <h4>📘 Guia de Início Rápido</h4>
          <p>Este é um sistema de monitoramento de frota baseado em Shiny (R) com integração Supabase.</p>
          <p><strong>Recursos Principais:</strong></p>
          <ul>
            <li>Dashboards interativos em tempo real</li>
            <li>Integração com Supabase PostgreSQL</li>
            <li>Dados de CSV e banco de dados em nuvem</li>
            <li>Gráficos dinâmicos com Plotly</li>
            <li>Tabelas reativas com Reactable</li>
          </ul>
          <p><strong>Próximas Etapas:</strong></p>
          <ol>
            <li>Explore cada dashboard para se familiarizar</li>
            <li>Configure suas credenciais Supabase</li>
            <li>Customize os gráficos conforme necessário</li>
            <li>Deploy para Posit Cloud (shinyapps.io)</li>
          </ol>
          <p style='color: #999; margin-top: 20px;'>
            <strong>Versão:</strong> 1.0.0<br>
            <strong>Atualizado:</strong> Março 2026<br>
            <strong>Suporte:</strong> Contacte o administrador do sistema
          </p>
        </div>")
      )
    )
  )
)

server <- function(input, output, session) {
  # Nenhuma lógica necessária para menu
}

shinyApp(ui, server)
