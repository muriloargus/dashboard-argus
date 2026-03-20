#!/usr/bin/env python3
"""
🚗 SINCRONIZAÇÃO GEOTAB → SUPABASE
Baixa dados do MyGeotab API Adapter e envia para Supabase
Script simples e automático
"""

import os
import psycopg2
import logging
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client

# Carrega arquivo .env
load_dotenv()

# ================= CONFIGURAÇÃO =================
GEOTAB_DB = {
    'host': os.getenv('GEOTAB_DB_HOST', 'localhost'),
    'database': os.getenv('GEOTAB_DB_NAME', 'mygeotab_adapter'),
    'user': os.getenv('GEOTAB_DB_USER', 'postgres'),
    'password': os.getenv('GEOTAB_DB_PASSWORD', 'password'),
    'port': int(os.getenv('GEOTAB_DB_PORT', 5432))
}

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

# Validar credenciais
if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError('❌ Configure SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no arquivo .env')

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sync_geotab.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ================= FUNÇÕES =================

def connect_geotab_db():
    """Conecta ao banco de dados local do MyGeotab Adapter"""
    try:
        conn = psycopg2.connect(**GEOTAB_DB)
        logger.info(f"✅ Conectado ao MyGeotab Adapter: {GEOTAB_DB['host']}:{GEOTAB_DB['port']}")
        return conn
    except Exception as e:
        logger.error(f"❌ Erro ao conectar MyGeotab DB: {e}")
        return None

def get_supabase_client():
    """Retorna cliente Supabase autenticado"""
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def sync_devices():
    """Sincroniza lista de dispositivos (veículos)"""
    logger.info("🚗 Sincronizando DISPOSITIVOS...")
    
    try:
        conn = connect_geotab_db()
        if not conn:
            return
        
        cur = conn.cursor()
        
        # Query para buscar dispositivos
        # Se sua tabela tem outro nome, ajuste aqui
        cur.execute("""
            SELECT 
                id,
                name,
                status,
                serialnumber,
                devicetype,
                activefrom,
                activeto,
                archived
            FROM device
            LIMIT 1000
        """)
        
        devices = cur.fetchall()
        
        if not devices:
            logger.warning("⚠️  Nenhum dispositivo encontrado no MyGeotab")
            cur.close()
            conn.close()
            return
        
        # Preparar dados para Supabase
        data = []
        for device in devices:
            data.append({
                'geotab_device_id': str(device[0]),
                'nome': device[1],
                'status': device[2],
                'numero_serie': device[3],
                'tipo_dispositivo': device[4],
                'ativo_desde': device[5],
                'ativo_ate': device[6],
                'arquivado': device[7],
                'sincronizado_em': datetime.now().isoformat()
            })
        
        # Enviar para Supabase
        supabase = get_supabase_client()
        
        # Upsert (insere ou atualiza)
        result = supabase.table('dispositivos_geotab').upsert(data, returning='minimal').execute()
        logger.info(f"✅ {len(data)} dispositivos sincronizados com sucesso!")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Erro ao sincronizar dispositivos: {e}")

def sync_status_records():
    """Sincroniza dados de status (GPS, velocidade, etc)"""
    logger.info("📍 Sincronizando STATUS RECORDS (GPS, velocidade)...")
    
    try:
        conn = connect_geotab_db()
        if not conn:
            return
        
        cur = conn.cursor()
        
        # Query para status records
        cur.execute("""
            SELECT 
                id,
                deviceid,
                latitude,
                longitude,
                speed,
                heading,
                datetime,
                odometer
            FROM statusdata
            ORDER BY datetime DESC
            LIMIT 5000
        """)
        
        records = cur.fetchall()
        
        if not records:
            logger.warning("⚠️  Nenhum status record encontrado")
            cur.close()
            conn.close()
            return
        
        # Preparar dados
        data = []
        for record in records:
            data.append({
                'geotab_id': str(record[0]),
                'device_id': str(record[1]),
                'latitude': float(record[2]) if record[2] else None,
                'longitude': float(record[3]) if record[3] else None,
                'velocidade_kmh': float(record[4]) if record[4] else None,
                'direcao': float(record[5]) if record[5] else None,
                'data_hora': record[6],
                'odometro_km': float(record[7]) if record[7] else None,
                'sincronizado_em': datetime.now().isoformat()
            })
        
        # Enviar para Supabase
        supabase = get_supabase_client()
        result = supabase.table('status_records_geotab').upsert(data, returning='minimal').execute()
        logger.info(f"✅ {len(data)} registros de status sincronizados!")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Erro ao sincronizar status records: {e}")

def sync_faults():
    """Sincroniza falhas do veículo"""
    logger.info("⚠️  Sincronizando FALHAS (diagnóstico)...")
    
    try:
        conn = connect_geotab_db()
        if not conn:
            return
        
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                id,
                deviceid,
                faultcode,
                description,
                datetime,
                cleardatetime,
                amplitude
            FROM fault
            ORDER BY datetime DESC
            LIMIT 2000
        """)
        
        faults = cur.fetchall()
        
        if not faults:
            logger.warning("⚠️  Nenhuma falha encontrada")
            cur.close()
            conn.close()
            return
        
        # Preparar dados
        data = []
        for fault in faults:
            data.append({
                'geotab_id': str(fault[0]),
                'device_id': str(fault[1]),
                'codigo_falha': fault[2],
                'descricao': fault[3],
                'data_ocorrencia': fault[4],
                'data_limpeza': fault[5],
                'amplitude': fault[6],
                'sincronizado_em': datetime.now().isoformat()
            })
        
        # Enviar para Supabase
        supabase = get_supabase_client()
        result = supabase.table('falhas_geotab').upsert(data, returning='minimal').execute()
        logger.info(f"✅ {len(data)} falhas sincronizadas!")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Erro ao sincronizar falhas: {e}")

def sync_drivers():
    """Sincroniza dados de motoristas"""
    logger.info("👤 Sincronizando MOTORISTAS...")
    
    try:
        conn = connect_geotab_db()
        if not conn:
            return
        
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                id,
                firstname,
                lastname,
                driverslicensenumber,
                employeeid,
                activefrom,
                activeto
            FROM user
            WHERE idriver IS NOT NULL
            LIMIT 1000
        """)
        
        drivers = cur.fetchall()
        
        if not drivers:
            logger.warning("⚠️  Nenhum motorista encontrado")
            cur.close()
            conn.close()
            return
        
        # Preparar dados
        data = []
        for driver in drivers:
            data.append({
                'geotab_driver_id': str(driver[0]),
                'nome': driver[1],
                'sobrenome': driver[2],
                'numero_cnh': driver[3],
                'employee_id': driver[4],
                'ativo_desde': driver[5],
                'ativo_ate': driver[6],
                'sincronizado_em': datetime.now().isoformat()
            })
        
        # Enviar para Supabase
        supabase = get_supabase_client()
        result = supabase.table('motoristas_geotab').upsert(data, returning='minimal').execute()
        logger.info(f"✅ {len(data)} motoristas sincronizados!")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        logger.error(f"❌ Erro ao sincronizar motoristas: {e}")

def main():
    """Executa todas as sincronizações"""
    logger.info("=" * 60)
    logger.info("🚀 INICIANDO SINCRONIZAÇÃO GEOTAB → SUPABASE")
    logger.info("=" * 60)
    
    try:
        sync_devices()
        sync_status_records()
        sync_faults()
        sync_drivers()
        
        logger.info("=" * 60)
        logger.info("✅ SINCRONIZAÇÃO COMPLETA COM SUCESSO!")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"❌ Erro geral na sincronização: {e}")

if __name__ == "__main__":
    main()
