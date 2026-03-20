#!/usr/bin/env bash
# Script para criar 14 dashboards Shiny a partir do template
# Use: bash criar_dashboards.sh

set -e

TEMPLATE_DIR="shiny/template_dashboard"
SHINY_DIR="shiny"

# Definir lista de dashboards
declare -a DASHBOARDS=(
  "dashboard_ativos:Ativos Cadastrados:ativos"
  "dashboard_motoristas:Desempenho de Motoristas:motoristas"
  "dashboard_usuarios:Análise de Usuários:usuarios"
  "dashboard_falhas:Histórico de Falhas:falhas"
  "dashboard_excecoes:Eventos Anormais:excecoes"
  "dashboard_comparativo:Análise Comparativa:ativos"
  "dashboard_desempenho:Desempenho Analista:ativos"
  "dashboard_dispositivos:Status de Dispositivos:ativos"
  "dashboard_timeline:Timeline de Eventos:ativos"
  "dashboard_risco:Risco de Colisão:ativos"
  "dashboard_temporal:Análise Temporal:ativos"
  "dashboard_tv:TV Dashboard:ativos"
  "dashboard_ativos_supabase:Ativos (Supabase):supabase"
  "dashboard_falhas_supabase:Falhas (Supabase):supabase"
)

echo "╔════════════════════════════════════════════════════════════════════════════════╗"
echo "║                  🚀 CRIAR 14 DASHBOARDS SHINY                                 ║"
echo "╚════════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar se template existe
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "❌ Erro: Pasta template não encontrada em $TEMPLATE_DIR"
  exit 1
fi

echo "✅ Template encontrado"
echo "📁 Criando 14 dashboards..."
echo ""

count=1
for dashboard in "${DASHBOARDS[@]}"; do
  IFS=':' read -r folder title table <<< "$dashboard"
  
  TARGET_DIR="$SHINY_DIR/$folder"
  
  echo "[$count/14] Criando: $title"
  
  # Copiar template
  if [ ! -d "$TARGET_DIR" ]; then
    cp -r "$TEMPLATE_DIR" "$TARGET_DIR"
    
    # Personalizar app.R
    if [[ "$table" == "supabase" ]]; then
      # Dashboard Supabase
      sed -i "" "s/DASHBOARD_TITLE <- .*/DASHBOARD_TITLE <- \"$title\"/" "$TARGET_DIR/app.R"
      sed -i "" 's/DATA_SOURCE <- "local"/DATA_SOURCE <- "supabase"/' "$TARGET_DIR/app.R"
    else
      # Dashboard CSV
      sed -i "" "s/DASHBOARD_TITLE <- .*/DASHBOARD_TITLE <- \"$title\"/" "$TARGET_DIR/app.R"
      sed -i "" "s/SUPABASE_TABLE <- .*/SUPABASE_TABLE <- \"$table\"/" "$TARGET_DIR/app.R"
    fi
    
    echo "     ✅ $folder criado"
  else
    echo "     ⏭️  $folder já existe (pulando)"
  fi
  
  ((count++))
done

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════════╗"
echo "║                        ✨ DASHBOARDS CRIADOS!                                 ║"
echo "╚════════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Estrutura criada em: shiny/"
echo ""
echo "🎯 Próximos passos:"
echo "   1. Personalize cada dashboard conforme necessário"
echo "   2. Teste localmente: shiny::runApp('shiny/dashboard_ativos')"
echo "   3. Deploy no Posit Cloud: rsconnect::deployApp('shiny/dashboard_ativos')"
echo ""
echo "📚 Veja más instruções em: shiny/template_dashboard/README.md"
echo ""
