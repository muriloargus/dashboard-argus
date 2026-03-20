#!/usr/bin/env python3
"""
🔧 FIX-DEPENDENCIAS - Instala tudo que está faltando
Execute este arquivo quando receber erro "ModuleNotFoundError"
"""

import subprocess
import sys

print("""
╔════════════════════════════════════════════════════════════╗
║  🔧 CORRIGINDO DEPENDÊNCIAS FALTANTES                     ║
╚════════════════════════════════════════════════════════════╝
""")

# Lista de bibliotecas necessárias
bibliotecas = [
    'supabase==2.4.5',
    'python-dotenv==1.0.0',
    'pandas==2.2.0',
    'requests==2.31.0'
]

print("📦 Instalando bibliotecas necessárias...\n")

for lib in bibliotecas:
    try:
        print(f"⏳ Instalando {lib}...")
        subprocess.check_call([
            sys.executable, '-m', 'pip', 'install', '-q', lib
        ])
        print(f"✅ {lib} instalado com sucesso!\n")
    except Exception as e:
        print(f"❌ Erro ao instalar {lib}: {str(e)}\n")

print("""
════════════════════════════════════════════════════════════════

✅ TUDO PRONTO!

Agora você pode executar:
   python pipeline.py

════════════════════════════════════════════════════════════════
""")
