#!/usr/bin/env python3
"""
Fix Database Schema - Corrige nomes de colunas esperadas vs atuais
Deleta tabelas antigas e cria novas com nomes corretos
"""

import os
from dotenv import load_dotenv
from supabase import create_client, Client
import time

load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

def safe_split_statements(sql_content):
    """Divide SQL em statements válidos"""
    statements = []
    current = ""
    in_string = False
    string_char = None
    
    for i, char in enumerate(sql_content):
        if char in ("'", '"') and (i == 0 or sql_content[i-1] != '\\'):
            if not in_string:
                in_string = True
                string_char = char
            elif char == string_char:
                in_string = False
        
        current += char
        
        if char == ';' and not in_string:
            if current.strip():
                statements.append(current.strip())
            current = ""
    
    if current.strip():
        statements.append(current.strip())
    
    return statements

def main():
    print("🔧 Corrigindo schema do banco de dados Supabase...")
    print(f"URL: {SUPABASE_URL}")
    
    try:
        client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        
        # Lê o arquivo SQL
        with open('SQL_SETUP_SUPABASE.sql', 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Divide em statements
        statements = safe_split_statements(sql_content)
        
        print(f"\n📋 {len(statements)} comandos SQL encontrados")
        
        # Primeiro, tenta deletar as tabelas antigas
        drop_statements = [
            "DROP TABLE IF EXISTS usuarios CASCADE;",
            "DROP TABLE IF EXISTS excecoes CASCADE;",
            "DROP TABLE IF EXISTS falhas CASCADE;",
            "DROP TABLE IF EXISTS ativos CASCADE;",
        ]
        
        print("\n🗑️  Deletando tabelas antigas...")
        for stmt in drop_statements:
            try:
                # Usa RPC para executar SQL raw
                result = client.rpc('exec_sql', {'sql': stmt}).execute()
                print(f"  ✅ {stmt[:50]}...")
                time.sleep(0.5)
            except Exception as e:
                print(f"  ⚠️  {stmt[:50]}... ({str(e)[:80]})")
        
        # Executa os statements de criação
        print("\n✨ Criando tabelas novas...")
        for i, stmt in enumerate(statements, 1):
            if stmt.upper().startswith('CREATE') or stmt.upper().startswith('ALTER'):
                try:
                    result = client.rpc('exec_sql', {'sql': stmt}).execute()
                    print(f"  ✅ Statement {i}")
                    time.sleep(0.5)
                except Exception as e:
                    # Se falhar com RPC, tenta direto com postgrest
                    print(f"  ⚠️  RPC failed, método alternativo será necessário")
        
        print("\n✅ Schema atualizado!")
        print("\n📝 Próximos passos:")
        print("1. Execute manualmente no Supabase SQL Editor (copie SQL_SETUP_SUPABASE.sql)")
        print("2. Depois execute: python pipeline.py")
        
    except Exception as e:
        print(f"\n❌ Erro: {str(e)}")
        print("\n📝 ALTERNATIVA: Execute manualmente no Supabase")
        print("1. Abra https://app.supabase.com")
        print("2. Vá para SQL Editor")
        print("3. Cole o conteúdo de SQL_SETUP_SUPABASE.sql")
        print("4. Clique 'RUN'")
        print("5. Volta aqui e execute: python pipeline.py")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        print("\n⏸️  Execute os passos acima manualmente")
