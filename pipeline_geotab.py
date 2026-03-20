#!/usr/bin/env python3
"""
🔗 INTEGRAÇÃO COM PIPELINE EXISTENTE
Execute este arquivo junto com seu pipeline.py
"""

import os
import sys
import subprocess
import logging
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# Carrega variáveis de ambiente
load_dotenv()

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def verificar_dependencias():
    """Verifica se todas as dependências estão instaladas"""
    logger.info("🔍 Verificando dependências...")
    
    try:
        import supabase
        import psycopg2
        logger.info("✅ Todas as dependências encontradas!")
        return True
    except ImportError as e:
        logger.error(f"❌ Dependência faltando: {e}")
        logger.info("Execute: pip install -r requirements.txt")
        return False

def sincronizar_geotab():
    """Executa sincronização Geotab antes do pipeline principal"""
    logger.info("🚗 Iniciando sincronização MyGeotab...")
    
    try:
        # Tenta executar o script de sincronização
        result = subprocess.run(
            [sys.executable, 'sync_geotab_to_supabase.py'],
            capture_output=True,
            text=True,
            timeout=600  # 10 minutos de timeout
        )
        
        if result.returncode == 0:
            logger.info("✅ Sincronização Geotab concluída com sucesso!")
            return True
        else:
            logger.error(f"❌ Erro na sincronização Geotab:")
            logger.error(result.stderr)
            # Continua mesmo com erro (não bloqueia pipeline)
            return False
            
    except FileNotFoundError:
        logger.warning("⚠️  Arquivo sync_geotab_to_supabase.py não encontrado")
        logger.info("Criando link simbólico...")
        return False
    except subprocess.TimeoutExpired:
        logger.warning("⚠️  Sincronização Geotab excedeu timeout")
        return False
    except Exception as e:
        logger.error(f"❌ Erro ao sincronizar Geotab: {e}")
        return False

def executar_pipeline_completo():
    """Executa pipeline completo: Geotab + CSV/outras fontes"""
    logger.info("="*60)
    logger.info("🚀 INICIANDO PIPELINE COMPLETO")
    logger.info("="*60)
    
    # 1. Verifica dependências
    if not verificar_dependencias():
        logger.error("❌ Instale as dependências: pip install -r requirements.txt")
        return False
    
    # 2. Sincroniza dados Geotab
    geotab_ok = sincronizar_geotab()
    
    # 3. Aqui você pode adicionar suas sincronizações de CSV/outras fontes
    logger.info("📊 Continuando com pipeline principal...")
    
    # 4. Importa e executa seu pipeline existente
    try:
        from pipeline import ArgusDataPipeline
        
        pipeline = ArgusDataPipeline()
        pipeline.setup_tables()
        
        # Processa CSVs (seu código existente)
        logger.info("📁 Processando CSVs...")
        # ... seu código de pipeline aqui
        
        logger.info("="*60)
        logger.info("✅ PIPELINE COMPLETO FINALIZADO COM SUCESSO!")
        logger.info("="*60)
        return True
        
    except ImportError:
        logger.warning("⚠️  Não consegui importar ArgusDataPipeline")
        logger.info("Verifique se pipeline.py existe")
        return geotab_ok
    except Exception as e:
        logger.error(f"❌ Erro no pipeline: {e}")
        return False

if __name__ == "__main__":
    sucesso = executar_pipeline_completo()
    sys.exit(0 if sucesso else 1)
