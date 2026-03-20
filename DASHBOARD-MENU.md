# 🎯 Dashboard Argus - Menu de Navegação

## Acesso ao Sistema

Todos os dashboards estão agora unificados com um menu central de navegação. 

### 🏠 **Menu Principal** 
- **Arquivo:** `dashboard_menu.html`
- **Descrição:** Página inicial com links para todos os dashboards disponíveis
- **Acesso:** Abra direto no navegador ou clique em "Menu" em qualquer dashboard

### 📊 **Dashboards Disponíveis**

#### 📦 **Dashboard Ativos**
- **Arquivo:** `dashboard_ativos_supabase.html`
- **Dados:** 1.764 dispositivos/veículos em operação
- **Visualizações:**
  - Estatísticas rápidas (Total, OK, Com Problemas, Última Atualização)
  - Gráfico de Status dos Dispositivos (Doughnut)
  - Gráfico de Tipos de Dispositivos (Bar)
  - Tabela pesquisável com filtro em tempo real

#### 🔴 **Dashboard Falhas**
- **Arquivo:** `dashboard_falhas_supabase.html`
- **Dados:** 6.534 registros de falhas reportadas
- **Visualizações:**
  - Estatísticas rápidas (Total Falhas, Devices com Falha, Falhas Ativas, Última Atualização)
  - Gráfico de Modo de Falha (Bar)
  - Gráfico de Fonte de Falha (Doughnut)
  - Tabela pesquisável com filtro por dispositivo e descrição

#### 👥 **Dashboard Usuários**
- **Arquivo:** `dashboard_usuarios_supabase.html`
- **Dados:** 467 usuários/operadores/motoristas
- **Visualizações:**
  - Estatísticas rápidas (Total Usuários, Grupos Únicos, Designações, Última Atualização)
  - Gráfico de Distribuição por Grupo (Bar)
  - Gráfico de Distribuição por Designação (Doughnut)
  - Diretório pesquisável com filtro por nome, email, grupo e designação

---

## 🔄 Sincronização de Dados

- ✅ **Banco de Dados:** Supabase PostgreSQL em tempo real
- ✅ **Atualização Automática:** A cada 6 horas via GitHub Actions
- ✅ **Última Sincronização:** Exibida em cada dashboard
- ✅ **Dados em Cache:** Modo offline disponível com localStorage

---

## 🚀 Como Usar

### Versão Local (Desenvolvedor)
```bash
# Clone o repositório
git clone https://github.com/muriloargus/dashboard-argus.git
cd dashboard-argus

# Abra no navegador
# Chrome/Edge: Abra dashboard_menu.html
```

### Versão Online (GitHub Pages)
```
Acesse: https://muriloargus.github.io/dashboard-argus/dashboard_menu.html
```

---

## 📋 Barra de Navegação

Cada dashboard possui uma barra de navegação com:
- **🏠 Menu** - Volta para a página inicial
- **📦 Ativos** - Acesso ao dashboard de ativos
- **🔴 Falhas** - Acesso ao dashboard de falhas
- **👥 Usuários** - Acesso ao dashboard de usuários

---

## 🔗 Links Diretos

Se preferir acessar um dashboard específico diretamente:

| Dashboard | Local | Online |
|-----------|-------|--------|
| Menu Principal | `dashboard_menu.html` | [Link GitHub Pages](https://muriloargus.github.io/dashboard-argus/dashboard_menu.html) |
| Ativos | `dashboard_ativos_supabase.html` | [Link GitHub Pages](https://muriloargus.github.io/dashboard-argus/dashboard_ativos_supabase.html) |
| Falhas | `dashboard_falhas_supabase.html` | [Link GitHub Pages](https://muriloargus.github.io/dashboard-argus/dashboard_falhas_supabase.html) |
| Usuários | `dashboard_usuarios_supabase.html` | [Link GitHub Pages](https://muriloargus.github.io/dashboard-argus/dashboard_usuarios_supabase.html) |

---

## ✨ Recursos

- ✅ Real-time data from Supabase
- ✅ Gráficos interativos com Chart.js
- ✅ Busca e filtro total
- ✅ Design responsivo (Mobile, Tablet, Desktop)
- ✅ AutoRefresh a cada 5 minutos
- ✅ Indicador de conexão
- ✅ Modo offline com cache

---

## 📞 Suporte

Para problemas de sincronização ou dúvidas:
1. Verifique se a conexão com Supabase está ativa
2. Consultex o console do navegador (F12) para logs
3. Veja o arquivo `.env` para credenciais corretas

**Última atualização:** Fevereiro 2025
