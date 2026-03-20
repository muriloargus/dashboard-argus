# Script to deploy all Shiny dashboards to Posit Cloud
# Usage: Rscript deploy_dashboards.R
# 
# Environment variables needed:
# - POSIT_TOKEN: Your Posit Cloud API token
# - POSIT_ACCOUNT_NAME: Your Posit Cloud account name

library(rsconnect)

# Configuration
POSIT_ACCOUNT_NAME <- Sys.getenv("POSIT_ACCOUNT_NAME", "seu-usuario")
POSIT_TOKEN <- Sys.getenv("POSIT_TOKEN")
POSIT_SECRET <- Sys.getenv("POSIT_SECRET")

# List of all dashboards to deploy
dashboards <- c(
  "dashboard_ativos",
  "dashboard_usuarios",
  "dashboard_motoristas",
  "dashboard_falhas",
  "dashboard_dispositivos",
  "dashboard_excecoes",
  "dashboard_timeline",
  "dashboard_temporal_mapas",
  "dashboard_risco_colisao",
  "dashboard_desempenho_analista",
  "dashboard_comparativo",
  "dashboard_ativos_supabase",
  "dashboard_falhas_supabase",
  "dashboard_usuarios_supabase",
  "dashboard_menu"
)

# Setup Posit Cloud connection
cat("Configurando conexão com Posit Cloud...\n")
rsconnect::setAccountInfo(
  account = POSIT_ACCOUNT_NAME,
  token = POSIT_TOKEN,
  secret = POSIT_SECRET
)

# Deploy each dashboard
cat("\nIniciando deployment dos dashboards...\n")
cat("=" %+% paste0(rep("=", 50), collapse = ""), "\n")

deployment_results <- list()

for (dashboard in dashboards) {
  dashboard_path <- file.path("shiny", dashboard)
  
  if (!dir.exists(dashboard_path)) {
    cat("❌ Dashboard não encontrado:", dashboard, "\n")
    deployment_results[[dashboard]] <- "NOT_FOUND"
    next
  }
  
  tryCatch({
    cat("\n📦 Deployando:", dashboard, "...\n")
    
    # Deploy to Posit Cloud
    rsconnect::deployApp(
      appDir = dashboard_path,
      appName = dashboard,
      account = POSIT_ACCOUNT_NAME,
      server = "shinyapps.io",
      launch.browser = FALSE,
      logLevel = "verbose"
    )
    
    cat("✅ Sucesso:", dashboard, "\n")
    deployment_results[[dashboard]] <- "SUCCESS"
    
  }, error = function(e) {
    cat("❌ Erro ao deployar:", dashboard, "\n")
    cat("   Detalhes:", e$message, "\n")
    deployment_results[[dashboard]] <<- "FAILED"
  })
}

# Summary report
cat("\n" %+% paste0(rep("=", 50), collapse = ""), "\n")
cat("RESUMO DO DEPLOYMENT\n")
cat(paste0(rep("=", 50), collapse = ""), "\n")

success_count <- sum(unlist(deployment_results) == "SUCCESS")
failed_count <- sum(unlist(deployment_results) == "FAILED")
not_found_count <- sum(unlist(deployment_results) == "NOT_FOUND")

cat("\nTotal de dashboards: ", length(dashboards), "\n")
cat("✅ Sucesso: ", success_count, "\n")
cat("❌ Falhas: ", failed_count, "\n")
cat("⚠️  Não encontrados: ", not_found_count, "\n")

cat("\nDetalhes:\n")
for (i in seq_along(deployment_results)) {
  dashboard <- names(deployment_results)[i]
  status <- deployment_results[[i]]
  
  icon <- if (status == "SUCCESS") "✅" else if (status == "FAILED") "❌" else "⚠️ "
  cat(sprintf("%s %s: %s\n", icon, dashboard, status))
}

cat("\n" %+% paste0(rep("=", 50), collapse = ""), "\n")
cat("Deployment concluído em: ", format(Sys.time(), "%d/%m/%Y %H:%M:%S"), "\n")

# Exit with appropriate code
if (failed_count > 0) {
  quit(status = 1)
} else {
  quit(status = 0)
}
