#!/usr/bin/env python3
"""
Testar acesso ao Supabase com chave ANON_KEY
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY')

print("🧪 Testando acesso ao Supabase com ANON_KEY")
print(f"URL: {SUPABASE_URL}")
print(f"Key: {SUPABASE_ANON_KEY[:20]}...")
print()

# Teste 1: Count
print("1️⃣  Testando COUNT da tabela ativos...")
url = f"{SUPABASE_URL}/rest/v1/ativos?select=count"
response = requests.get(url, headers={
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}'
})
print(f"Status: {response.status_code}")
print(f"Response: {response.text[:200]}\n")

# Teste 2: SELECT *
print("2️⃣  Testando SELECT * da tabela ativos...")
url = f"{SUPABASE_URL}/rest/v1/ativos?select=*&limit=1"
response = requests.get(url, headers={
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}'
})
print(f"Status: {response.status_code}")
print(f"Response: {response.text[:200]}\n")

# Teste 3: TABLE INFO
print("3️⃣  Verificando informações da tabela...")
url = f"{SUPABASE_URL}/rest/v1/?select=table_name"
response = requests.get(url, headers={
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}'
})
print(f"Status: {response.status_code}")
print(f"Response: {response.text}\n")

print("✅ Teste concluído!")
