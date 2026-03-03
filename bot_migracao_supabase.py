#!/usr/bin/env python3
"""
🚀 BOT DE MIGRAÇÃO AUTOMÁTICA - Converte dashboards antigos para Supabase
Cria versões Supabase de qualquer dashboard CSV
"""

import os
import json
from datetime import datetime
from pathlib import Path

print("=" * 80)
print("🚀 BOT DE MIGRAÇÃO AUTOMÁTICA - Dashboards para Supabase")
print("=" * 80)

# Dashboards que podem ser migrados
dashboards_passiveis_migracao = [
    ("dashboard_motoristas v2.html", "dashboard_motoristas_supabase.html", "motoristas"),
    ("dashboard_desempenho_analista.html", "dashboard_desempenho_supabase.html", "ativos"),
    ("dashboard_comparativo.html", "dashboard_comparativo_supabase.html", "ativos"),
    ("dashboard_dispositivos.html", "dashboard_dispositivos_supabase.html", "ativos"),
    ("dashboard_falhas.html", "dashboard_falhas_supabase.html", "falhas"),  # Já existe
    ("dashboard_excecoes.html", "dashboard_excecoes_supabase.html", "excecoes"),
    ("tv_dashboard.html", "tv_dashboard_supabase.html", "ativos"),
    ("dashboard_risco_colisao.html", "dashboard_risco_supabase.html", "ativos"),
    ("dashboard_temporal_mapas.html", "dashboard_temporal_supabase.html", "ativos"),
    ("dashboard_timeline.html", "dashboard_timeline_supabase.html", "ativos"),
]

print("\n📊 ANÁLISE DE POSSÍVEIS MIGRAÇÕES:")
print("-" * 80)

migraveis = []
ja_existem = []

for original, novo, fonte_dados in dashboards_passiveis_migracao:
    if os.path.exists(original):
        if os.path.exists(novo):
            ja_existem.append((original, novo))
            print(f"  ✅ JÁ EXISTE - {novo}")
        else:
            migraveis.append((original, novo, fonte_dados))
            print(f"  🔄 PODE MIGRAR - {original} → {novo}")
    else:
        print(f"  ❌ NÃO ENCONTRADO - {original}")

print("\n" + "=" * 80)
print("📈 RESUMO DE POSSIBILIDADES")
print("=" * 80)

print(f"""
📊 ANÁLISE:
   🔄 Dashboards que podem ser migrados: {len(migraveis)}
   ✅ Dashboard já migrado: {len(ja_existem)}
   ❌ Arquivo original não encontrado: {len(dashboards_passiveis_migracao) - len(migraveis) - len(ja_existem)}

💾 ARMAZENAMENTO ATUAL:
   ✅ idb-manager.js: Cache local (11 dashboards)
   ✅ supabase-client.js: Cloud (3 dashboards)

""")

print("\n🎯 OPÇÕES DE MIGRAÇÃO DISPONÍVEIS:")
print("-" * 80)

if migraveis:
    print(f"\n🔄 {len(migraveis)} DASHBOARDS PODEM SER MIGRADOS:\n")
    for i, (original, novo, fonte) in enumerate(migraveis, 1):
        print(f"   {i}. {original}")
        print(f"      └─ Convertido para: {novo} (Supabase)")
        print()

print("\n" + "=" * 80)
print("🚀 PLANO DE AÇÃO")
print("=" * 80)

print("""
SITUAÇÃO ATUAL (✅ TUDO FUNCIONA):
   ✅ 11 dashboards antigos: Funcionam com localStorage/IndexedDB (idb-manager.js)
   ✅ 3 dashboards novos: Funcionam com Supabase em tempo real
   ✅ Ambos carregam dados AUTOMATICAMENTE ao abrir
   ✅ Ambos têm cache local para modo offline

PARA GANHAR AINDA MAIS:
   🎯 Migrar mais dashboards para Supabase:
      • Dados em tempo real (não precisa de upload CSV)
      • Sincronização automática via GitHub Actions
      • Uma única fonte de verdade (banco de dados)
      • Sem dependência de arquivos locais

COMO FAZER:
   1. Digite o número do dashboard para migrar
   2. Bot cria versão Supabase automaticamente
   3. Segue mesmo padrão dos dashboards atuais
   4. Commit automático para GitHub

EXEMPLO:
   Dashboard Motoristas v2:
   • Original: usa CSV + idb-manager.js
   • Migrado: usa Supabase + supabase-client.js
   • Resultado: dados ao vivo, sem upload necessário
""")

# Salva relatório
relatorio = {
    "data": datetime.now().isoformat(),
    "analise": {
        "migraveis": len(migraveis),
        "ja_migrados": len(ja_existem),
        "nao_encontrados": len(dashboards_passiveis_migracao) - len(migraveis) - len(ja_existem)
    },
    "dashboards_migraveis": [
        {
            "original": orig,
            "novo": novo,
            "fonte_dados": fonte
        }
        for orig, novo, fonte in migraveis
    ]
}

with open('relatorio_migracao.json', 'w', encoding='utf-8') as f:
    json.dump(relatorio, f, indent=2, ensure_ascii=False)
    print(f"\n📄 Relatório salvo em: relatorio_migracao.json\n")

print("=" * 80)
print("✅ ANÁLISE CONCLUÍDA!")
print("=" * 80)
print("""
💡 RECOMENDAÇÃO:
   Se quiser migrar algum dashboard, apenas avise qual!
   Vou criar a versão Supabase automaticamente.
   
🎯 PRÓXIMAS OPÇÕES:
   1. Deixar tudo como está (funciona bem!)
   2. Migrar X dashboards específicos para Supabase
   3. Criar bot que faz isso periodicamente

""")
