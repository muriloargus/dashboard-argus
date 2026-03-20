#!/usr/bin/env python3
"""
🚗 INSERIR DADOS DE TESTE NO SUPABASE
Popula as tabelas com dados fictícios para demonstração
"""

import os
from datetime import datetime, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client
import random

# Carrega variáveis de ambiente
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError('❌ Configure SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no .env')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ================= DADOS DE TESTE =================

DISPOSITIVOS = [
    {'geotab_device_id': 'DEV001', 'nome': 'Volvo FH 2024', 'status': 'Em Movimento', 'numero_serie': 'VLV123456', 'tipo_dispositivo': 'Trator'},
    {'geotab_device_id': 'DEV002', 'nome': 'Scania R450', 'status': 'Em Parada', 'numero_serie': 'SCA789012', 'tipo_dispositivo': 'Trator'},
    {'geotab_device_id': 'DEV003', 'nome': 'Mercedes Atego', 'status': 'Em Movimento', 'numero_serie': 'MRC345678', 'tipo_dispositivo': 'Caminhão'},
    {'geotab_device_id': 'DEV004', 'nome': 'Ford Cargo', 'status': 'Offline', 'numero_serie': 'FRD901234', 'tipo_dispositivo': 'Caminhão'},
    {'geotab_device_id': 'DEV005', 'nome': 'Iveco Stralis', 'status': 'Em Movimento', 'numero_serie': 'IVC567890', 'tipo_dispositivo': 'Trator'},
]

MOTORISTAS = [
    {'geotab_driver_id': 'DRV001', 'nome': 'João', 'sobrenome': 'Silva', 'numero_cnh': '12345678900', 'employee_id': 'EMP001'},
    {'geotab_driver_id': 'DRV002', 'nome': 'Maria', 'sobrenome': 'Santos', 'numero_cnh': '98765432100', 'employee_id': 'EMP002'},
    {'geotab_driver_id': 'DRV003', 'nome': 'Pedro', 'sobrenome': 'Oliveira', 'numero_cnh': '55555555500', 'employee_id': 'EMP003'},
]

CODIGOS_FALHA = ['P0101', 'P0102', 'P0103', 'P0105', 'P0110', 'P0111', 'P0112', 'P0113']
DESCRICOES_FALHA = [
    'Sensor de Fluxo de Ar Defeituoso',
    'Sensor de Oxigênio Defeituoso',
    'Falha na Injeção de Combustível',
    'Pressão de Óleo Baixa',
    'Temperatura do Motor Alta',
    'Bateria Fraca',
    'Sistema de Arrefecimento com Problema',
    'Embreagem Desgastada'
]

def inserir_dispositivos():
    """Insere dispositivos de teste"""
    print("🚗 Inserindo dispositivos de teste...")
    
    data_teste = []
    for dev in DISPOSITIVOS:
        data_teste.append({
            'geotab_device_id': dev['geotab_device_id'],
            'nome': dev['nome'],
            'status': dev['status'],
            'numero_serie': dev['numero_serie'],
            'tipo_dispositivo': dev['tipo_dispositivo'],
            'ativo_desde': '2023-01-15',
            'ativo_ate': None,
            'arquivado': False,
            'sincronizado_em': datetime.now().isoformat()
        })
    
    result = supabase.table('dispositivos_geotab').upsert(data_teste, returning='minimal').execute()
    print(f"✅ {len(data_teste)} dispositivos inseridos!")

def inserir_status_records():
    """Insere registros de status (GPS, velocidade)"""
    print("📍 Inserindo registros de status...")
    
    data_teste = []
    
    for dev in DISPOSITIVOS:
        for i in range(50):  # 50 registros por dispositivo
            # Gera dados aleatórios
            latitude = random.uniform(-23.5, -23.4)  # São Paulo area
            longitude = random.uniform(-46.6, -46.5)
            velocidade = random.randint(0, 120)
            direcao = random.randint(0, 360)
            odometro = random.uniform(100000, 500000)
            
            # Timestamps variados nos últimos 7 dias
            tempo = datetime.now() - timedelta(hours=random.randint(0, 168))
            
            data_teste.append({
                'geotab_id': f'{dev["geotab_device_id"]}_STATUS_{i}',
                'device_id': dev['geotab_device_id'],
                'latitude': latitude,
                'longitude': longitude,
                'velocidade_kmh': velocidade,
                'direcao': direcao,
                'data_hora': tempo.isoformat(),
                'odometro_km': odometro,
                'sincronizado_em': datetime.now().isoformat()
            })
    
    result = supabase.table('status_records_geotab').upsert(data_teste, returning='minimal').execute()
    print(f"✅ {len(data_teste)} registros de status inseridos!")

def inserir_falhas():
    """Insere falhas de diagnóstico"""
    print("⚠️  Inserindo falhas de diagnóstico...")
    
    data_teste = []
    
    for dev in DISPOSITIVOS[:3]:  # Apenas alguns dispositivos têm falhas
        for i in range(random.randint(2, 5)):  # 2-5 falhas por dispositivo
            data_ocorrencia = datetime.now() - timedelta(days=random.randint(1, 30))
            
            data_teste.append({
                'geotab_id': f'{dev["geotab_device_id"]}_FAULT_{i}',
                'device_id': dev['geotab_device_id'],
                'codigo_falha': random.choice(CODIGOS_FALHA),
                'descricao': random.choice(DESCRICOES_FALHA),
                'data_ocorrencia': data_ocorrencia.isoformat(),
                'data_limpeza': None,  # Algumas não limpas
                'amplitude': random.uniform(0, 100),
                'sincronizado_em': datetime.now().isoformat()
            })
    
    result = supabase.table('falhas_geotab').upsert(data_teste, returning='minimal').execute()
    print(f"✅ {len(data_teste)} falhas inseridas!")

def inserir_motoristas():
    """Insere motoristas de teste"""
    print("👤 Inserindo motoristas...")
    
    data_teste = []
    for drv in MOTORISTAS:
        data_teste.append({
            'geotab_driver_id': drv['geotab_driver_id'],
            'nome': drv['nome'],
            'sobrenome': drv['sobrenome'],
            'numero_cnh': drv['numero_cnh'],
            'employee_id': drv['employee_id'],
            'ativo_desde': '2022-06-01',
            'ativo_ate': None,
            'sincronizado_em': datetime.now().isoformat()
        })
    
    result = supabase.table('motoristas_geotab').upsert(data_teste, returning='minimal').execute()
    print(f"✅ {len(data_teste)} motoristas inseridos!")

def main():
    print("=" * 60)
    print("🚀 INSERINDO DADOS DE TESTE NO SUPABASE")
    print("=" * 60)
    
    try:
        inserir_dispositivos()
        inserir_status_records()
        inserir_falhas()
        inserir_motoristas()
        
        print("=" * 60)
        print("✅ DADOS DE TESTE INSERIDOS COM SUCESSO!")
        print("=" * 60)
        print("\n📊 Resumo dos dados inseridos:")
        print(f"  • {len(DISPOSITIVOS)} dispositivos")
        print(f"  • {len(DISPOSITIVOS) * 50} registros de status")
        print(f"  • ~{sum([random.randint(2, 5) for _ in range(3)])} falhas distribuídas")
        print(f"  • {len(MOTORISTAS)} motoristas")
        print("\n✅ Dados estão prontos no Supabase!")
        print("✅ Você pode ver tudo em: app.supabase.com → Table Editor")
        
    except Exception as e:
        print(f"❌ Erro ao inserir dados: {e}")

if __name__ == "__main__":
    main()
