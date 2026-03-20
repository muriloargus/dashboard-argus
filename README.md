# 📊 Argus Dashboard Platform

Sistema de visualização de telemetria e monitoramento de frota para CCO Ambev.

## 🎯 Dashboards Disponíveis

- 📍 **Dashboard Principal** - Visão geral da operação
- 🚗 **Motoristas** - Performance e histórico de condutores  
- 📦 **Ativos** - Rastreamento de frota
- 👥 **Usuários** - Análise de usuários (drivers e ambev)
- 🔴 **Exceções** - Eventos anormais detectados
- ⚠️ **Falhas** - Histórico de falhas técnicas
- 📈 **Comparativo** - Análise comparada de métricas
- 🎯 **Desempenho Analista** - KPIs por analista
- 📱 **Dispositivos** - Status de aparelhos GPS
- 💥 **Risco de Colisão** - Detecção preventiva
- 🗺️ **Temporal/Mapas** - Análise espaço-temporal
- ⏱️ **Timeline** - Eventos em sequência temporal
- 📺 **TV Dashboard** - Tela de monitoramento em tempo real

## 🚀 Como Usar

1. Abra `index.html` no navegador
2. Selecione o dashboard desejado no menu lateral
3. Importe seus arquivos CSV ou visualize dados armazenados

## 💾 Armazenamento

- **IndexedDB** - Capacidade de até 1GB (dados pesados)
- **localStorage** - Compatibilidade automática com fallback
- **Compressão** - Automática para arquivos >2MB

## 📁 Estrutura

```
dashboard_argus/
├── index.html                          # Portal principal
├── dashboard_*.html                    # Dashboards temáticos
├── storage-adapter.js                  # Gerenciamento de storage
├── idb-manager.js                      # IndexedDB com compressão
├── *.csv                               # Dados amostra
└── README.md                           # Este arquivo
```

## 🛠️ Tecnologias

- HTML5 / CSS3 / JavaScript ES6+
- Chart.js - Gráficos interativos
- Bootstrap 5 - Interface responsiva
- IndexedDB - Storage de grandes volumes

## 📝 Dados

Os dashboards aceitam arquivos CSV com as seguintes colunas base:

- Timestamp
- Identificador (motorista, dispositivo, etc)
- Valor métrica
- Status

## 🔧 Customização

Cada dashboard é independente e pode ser customizado via CSS e JavaScript da página HTML.

## 📞 Suporte

Para dúvidas, verifique os arquivos de documentação técnica:
- `DETALHES-TECNICO-DO-FIX.md` - Implementação IndexedDB
- `README-RECUPERACAO.md` - Recovery de dados
- `GUIA-RAPIDO.html` - Guia rápido de uso

---

**v1.0** - Plataforma Argus Dashboard
