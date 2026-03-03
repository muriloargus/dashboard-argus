#!/usr/bin/env python3
"""
Limpar CSVs - Remove caracteres inválidos e padroniza datas
"""

import pandas as pd
from pathlib import Path
import os

def limpar_dados():
    """Limpa e padroniza os CSVs antes de sincronizar"""
    
    input_dir = Path('./input')
    columns_to_skip = {}  # Colunas que não têm na tabela
    
    # Processar ATIVOS
    ativos_path = list(input_dir.glob('*ativos*.csv'))[0]
    print(f"🗂️  Limpando {ativos_path.name}...")
    df = pd.read_csv(ativos_path, sep=';', encoding='utf-8')
    
    # Remove colunas que não existem no Supabase
    cols_para_remover = [c for c in df.columns if c not in [
        'Dispositivo', 'Grupo de dispositivo', 'Device ID', 'Nome', 'Sobrenome',
        'Motorista atual', 'Horário de trabalho', 'Atividade atual', 'In Privacy Mode',
        'Últimos tipos da zona de parada', 'Hodômetro atual', 'Horas de motor atuais',
        'Ativo desde', 'Ativo até', 'Está arquivado (histórico)', 'Plano',
        'Tipo de dispositivo', 'Versão de firmware', 'Nº de série', 'Placa',
        'Placa/Província:', 'VIN', 'Zona horária', 'Comentário do dispositivo'
    ]]
    
    df = df.drop(columns=cols_para_remover, errors='ignore')
    print(f"  ✅ Removidas colunas extras: {cols_para_remover}")
    
    # Processa datas - remove valores inválidos
    date_cols = ['Ativo desde', 'Ativo até', 'Última viagem', 'Última data de comunicação']
    for col in date_cols:
        if col in df.columns:
            # Remove linhas com valores não-data
            df[col] = pd.to_datetime(df[col], errors='coerce')
    
    df.to_csv(ativos_path, sep=';', encoding='utf-8', index=False)
    print(f"  ✅ {ativos_path.name} limpo\n")
    
    # Processar FALHAS
    falhas_path = input_dir / 'falhas.csv'
    if falhas_path.exists():
        print(f"🗂️  Limpando {falhas_path.name}...")
        df = pd.read_csv(falhas_path, sep=';', encoding='utf-8')
        
        # Garante que colunas de data são válidas
        date_cols = ['Data', 'Data de extinção do defeito']
        for col in date_cols:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors='coerce')
        
        df.to_csv(falhas_path, sep=';', encoding='utf-8', index=False)
        print(f"  ✅ {falhas_path.name} limpo\n")
    
    # Processar USUÁRIOS
    usuarios_path = list(input_dir.glob('*usuarios*.csv'))[0]
    if usuarios_path.exists():
        print(f"🗂️  Limpando {usuarios_path.name}...")
        df = pd.read_csv(usuarios_path, sep=';', encoding='utf-8')
        
        # Garante que tem as 5 colunas esperadas
        expected = ['NOME COMPLETO', 'E-mail', 'Grupo', 'Designação', 'CPF']
        df = df[[c for c in expected if c in df.columns]]
        
        df.to_csv(usuarios_path, sep=';', encoding='utf-8', index=False)
        print(f"  ✅ {usuarios_path.name} limpo\n")
    
    print("✅ Todos os CSVs foram limpos!")
    return True

if __name__ == "__main__":
    try:
        limpar_dados()
        print("\n👉 Próximo: Execute python pipeline.py")
    except Exception as e:
        print(f"\n❌ Erro: {str(e)}")
