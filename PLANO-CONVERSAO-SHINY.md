# 🚀 PLANO DE CONVERSÃO: HTML → SHINY (14 dashboards)

## 📊 ESTRUTURA ATUAL (HTML)

**Dashboards CSV (11):**
1. Dashboard Motoristas v2
2. Dashboard Ativos
3. Dashboard Usuarios
4. Dashboard Comparativo
5. Dashboard Desempenho Analista
6. Dashboard Dispositivos
7. Dashboard Falhas
8. Dashboard Excecoes
9. Dashboard Risco Colisão
10. Dashboard Temporal/Mapas
11. Dashboard Timeline
12. TV Dashboard

**Dashboards Supabase (3):**
- Dashboard Ativos (Supabase)
- Dashboard Falhas (Supabase)
- Dashboard Usuarios (Supabase)

---

## 🔄 CONVERSÃO: HTML → SHINY

### **Tecnologia Stack**
```
HTML/CSS/JS (localStorage, Chart.js)
        ↓
    SHINY (R)
    ├─ UI: Bootstrap themes (shinydashboard / bslib)
    ├─ Gráficos: plotly (renderPlotly) ou ggplot2
    ├─ Dados: Supabase + CSV (readr)
    └─ Reatividade: Shiny reactive expressions
```

### **Vantagens da Conversão**
✅ Uma única linguagem (R)
✅ Reatividade real (sem JS manual)
✅ Integração fácil com análise estatística
✅ Deploy automático (Posit Cloud)
✅ Melhor performance em grandes datasets
✅ Menos código de manutenção

---

## 📋 PLANO DE IMPLEMENTAÇÃO

### **FASE 1: Estrutura Base (1 dashboard como template)**

```
shiny/
├── 01_dashboard_ativos/
│   ├── app.R (Shiny app)
│   ├── global.R (dados, funções compartilhadas)
│   ├── ui.R (interface)
│   └── server.R (lógica reativa)
│
├── 02_dashboard_motoristas/
│   ├── app.R
│   ├── global.R
│   ├── ui.R
│   └── server.R
│
├── ... (12 mais)
│
└── shiny_master.R (rodar todos em paralelo)
```

### **FASE 2: Biblioteca Compartilhada**

```
shiny/
└── shared/
    ├── supabase_functions.R (conectar Supabase)
    ├── csv_functions.R (ler CSVs)
    ├── theme.R (estilo consistente)
    └── helpers.R (funções utilitárias)
```

### **FASE 3: Automação**

```
GitHub Actions:
├── deploy_shiny.yml → Deploy automático no Posit Cloud
├── sync_data.yml → Atualizar dados a cada 6h
└── test_shiny.yml → Testes antes de deploy
```

---

## 🎯 CRONOGRAMA SUGERIDO

| Fase | Duração | Atividade |
|------|---------|-----------|
| 1 | 2-3 horas | Criar template Shiny base + dashboard exemplo |
| 2 | 2-3 horas | Converter 3 dashboards CSV |
| 3 | 3-4 horas | Converter 3 dashboards Supabase |
| 4 | 2-3 horas | Converter 8 dashboards restantes |
| 5 | 1-2 horas | Testes e ajustes |
| 6 | 1 hora | Setup GitHub Actions para deploy |
| **Total** | **11-16 horas** | **Tudo convertido e automatizado** |

---

## 💡 OPÇÕES DE IMPLEMENTAÇÃO

### **Opção A: Converter Tudo Agora** (Recomendado)
- Começar com 1 dashboard como template
- Clonar para os 13 restantes
- Automatizar deploy
- Tempo: 1-2 dias

### **Opção B: Híbrido (HTML + Shiny)**
- Manter HTML para dashboards simples
- Shiny só para dashboards complexos
- Coexistir no mesmo projeto
- Tempo: 1 semana gradualmente

### **Opção C: Migração Gradual**
- 1 dashboard Shiny por semana
- Manter HTML rodando em paralelo
- Sem pressa
- Tempo: 14 semanas

---

## 📦 DEPENDÊNCIAS R NECESSÁRIAS

```r
install.packages(c(
  "shiny",                    # Framework base
  "shinydashboard",           # Tema dashboard
  "bslib",                    # Bootstrap 5 themes
  "plotly",                   # Gráficos interativos
  "ggplot2",                  # Gráficos estáticos
  "dplyr",                    # Manipulação dados
  "readr",                    # Ler CSVs
  "DBI",                      # Conexão bancos
  "RPostgres",                # PostgreSQL (Geotab)
  "supabaseR",                # Supabase R client
  "reactable",                # Tabelas interativas
  "shinyjs",                  # JavaScript com Shiny
  "shinythemes"               # Temas adicionais
))
```

---

## 🔑 COMO COMEÇAR?

### **Passo 1: Você quer que eu crie agora:**

- [ ] Template Shiny base (app.R inicial)
- [ ] Dashboard Ativos em Shiny (como exemplo)
- [ ] Setup GitHub Actions para deploy
- [ ] Documentação de como clonar para 13 dashboards

### **Passo 2: Depois você pode:**

- Clonar o template para cada dashboard
- Ajustar dados + gráficos
- Testar localmente
- Deploy automático no Posit Cloud

---

## ✅ PRÓXIMAS AÇÕES

👉 **O que você prefere?**

1. **Começar agora:** Criar template + 1 dashboard exemplo
2. **Informações:** Ver exemplo de app.R Shiny
3. **Planejar:** Detalhar a estratégia de cada dashboard
4. **Outro:** Sua preferência?

---

**Recomendação:** Comece com **OPÇÃO A** (Converter Tudo Agora com template).
Leva 1-2 dias mas depois é totalmente automatizado!

Quer que eu comece? 🚀
