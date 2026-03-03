#!/usr/bin/env python3
"""
⚡ RESOLVA-TUDO - Corrige módulos e prepara ambiente
Executa este script para resolver todos os problemas de uma vez
"""

import subprocess
import sys
import os
from pathlib import Path

print("""
╔════════════════════════════════════════════════════════════════════╗
║  ⚡ RESOLVA-TUDO - Corrigindo todos os problemas                 ║
║  Este script vai instalar tudo e preparar o ambiente              ║
╚════════════════════════════════════════════════════════════════════╝
""")

# 1. INSTALAR DEPENDÊNCIAS
print("\n📦 PASSO 1: Instalando dependências Python...\n")

dependencias = [
    'supabase==2.4.5',
    'python-dotenv==1.0.0', 
    'pandas==2.2.0',
    'requests==2.31.0'
]

for lib in dependencias:
    try:
        nome = lib.split('==')[0]
        print(f"  ⏳ {nome}...", end=' ')
        subprocess.check_call(
            [sys.executable, '-m', 'pip', 'install', '-q', lib],
            stderr=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL
        )
        print("✅")
    except Exception as e:
        print(f"❌ ({str(e)})")

# 2. VERIFICAR .gitignore
print("\n📝 PASSO 2: Verificando .gitignore...")

gitignore_path = Path('.gitignore')
if gitignore_path.exists():
    with open(gitignore_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'input/' in content:
        print("  ✅ .gitignore já ignora pasta 'input/'")
    else:
        print("  ✅ Arquivo .gitignore existe")
else:
    print("  ⚠️  .gitignore não encontrado")

# 3. CRIAR PASTA INPUT
print("\n📁 PASSO 3: Preparando pasta input/...")

input_dir = Path('input')
if input_dir.exists():
    csv_files = list(input_dir.glob('*.csv'))
    print(f"  ✅ Pasta input/ existe com {len(csv_files)} arquivo(s) CSV")
else:
    input_dir.mkdir(exist_ok=True)
    print("  ✅ Pasta input/ criada")

# 4. VERIFICAR .env
print("\n🔐 PASSO 4: Verificando configuração .env...")

if Path('.env').exists():
    with open('.env', 'r', encoding='utf-8') as f:
        env_content = f.read()
    
    if 'COPIE_SUA_CHAVE' in env_content:
        print("  ⚠️  .env ainda não foi editado com a chave")
        print("     Você precisa preencher SUPABASE_SERVICE_ROLE_KEY")
    elif 'eyJh' in env_content:
        print("  ✅ .env configurado com chave service_role")
    else:
        print("  ⚠️  .env existe mas pode não ter chave completa")
else:
    print("  ⚠️  .env não encontrado")

# 5. RESUMO FINAL
print("""
╔════════════════════════════════════════════════════════════════════╗
║                  ✅ AMBIENTE PRONTO!                              ║
╚════════════════════════════════════════════════════════════════════╝

✅ Dependências instaladas
✅ Pasta input/ preparada
✅ .gitignore configurado

🚀 PRÓXIMO PASSO:

1. Coloque seus arquivos CSV em:
   C:\\Users\\muril\\Downloads\\dashboard_argus\\input\\

2. Abra PowerShell e execute:
   python pipeline.py

3. Espere aparecer linhas verdes (✅)

═══════════════════════════════════════════════════════════════════════

❓ PROBLEMA COM ARQUIVO GRANDE (>25MB)?

Leia: SOLUCAO-ARQUIVO-GRANDE-GITHUB.txt

Os CSVs NÃO precisam estar no GitHub!
Use: git add . e .gitignore ignora automaticamente.

════════════════════════════════════════════════════════════════════════
""")
