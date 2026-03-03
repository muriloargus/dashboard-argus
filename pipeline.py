#!/usr/bin/env python3
"""
Pipeline Argus - Sincroniza dados de CSV para Supabase
Automatiza a atualização de dashboards sem necessidade de CSVs
"""

import os
import csv
import json
import unicodedata
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client
import pandas as pd
import sys

# Carrega variáveis de ambiente
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')
CSV_FOLDER = os.getenv('CSV_FOLDER', './input')

class ArgusDataPipeline:
    def __init__(self):
        if not SUPABASE_URL or not SUPABASE_KEY:
            raise ValueError('❌ SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY não configuradas')
        
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        self.log = []
        
    def log_message(self, message: str, level: str = 'INFO'):
        """Registra mensagens de execução"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f'[{timestamp}] [{level}] {message}'
        print(log_entry)
        self.log.append(log_entry)
    
    def setup_tables(self):
        """Cria tabelas no Supabase se não existirem"""
        self.log_message('🗂️  Verificando estrutura de tabelas...')
        
        try:
            # Verifica se já existem tabelas
            self.supabase.table('ativos').select('id').limit(1).execute()
            self.log_message('✅ Tabelas já existem')
            return
        except:
            pass
        
        # SQL para criar tabelas
        sql_queries = [
            """
            CREATE TABLE IF NOT EXISTS ativos (
                id SERIAL PRIMARY KEY,
                dispositivo VARCHAR(50),
                grupo_dispositivo TEXT,
                device_id VARCHAR(50),
                nome VARCHAR(100),
                sobrenome VARCHAR(100),
                motorista_atual VARCHAR(100),
                horario_trabalho VARCHAR(50),
                atividade_atual VARCHAR(50),
                privacy_mode BOOLEAN,
                endereco_parada TEXT,
                odometro_atual FLOAT,
                horas_motor FLOAT,
                ativo_desde DATE,
                ativo_ate DATE,
                arquivado BOOLEAN,
                plano VARCHAR(200),
                tipo_dispositivo VARCHAR(100),
                versao_firmware VARCHAR(50),
                numero_serie VARCHAR(50),
                placa VARCHAR(50),
                vin VARCHAR(50),
                zona_horaria VARCHAR(50),
                status_download VARCHAR(100),
                ultima_viagem DATE,
                ultima_comunicacao TIMESTAMP,
                criado_em TIMESTAMP DEFAULT NOW(),
                atualizado_em TIMESTAMP DEFAULT NOW()
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS falhas (
                id SERIAL PRIMARY KEY,
                dispositivo VARCHAR(50),
                grupo_dispositivo TEXT,
                data_falha TIMESTAMP,
                data_extincao TIMESTAMP,
                usuario_extincao VARCHAR(100),
                descricao TEXT,
                modo_falha VARCHAR(100),
                fonte VARCHAR(100),
                controlador VARCHAR(100),
                codigo VARCHAR(50),
                criado_em TIMESTAMP DEFAULT NOW(),
                atualizado_em TIMESTAMP DEFAULT NOW()
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS excecoes (
                id SERIAL PRIMARY KEY,
                data_evento TIMESTAMP,
                evento VARCHAR(200),
                tipo VARCHAR(100),
                dispositivo VARCHAR(50),
                motorista VARCHAR(100),
                localizacao TEXT,
                status VARCHAR(50),
                criado_em TIMESTAMP DEFAULT NOW(),
                atualizado_em TIMESTAMP DEFAULT NOW()
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS usuarios (
                id SERIAL PRIMARY KEY,
                usuario_id VARCHAR(50),
                nome VARCHAR(100),
                email VARCHAR(100),
                tipo_usuario VARCHAR(50),
                departamento VARCHAR(100),
                status VARCHAR(50),
                criado_em TIMESTAMP DEFAULT NOW(),
                atualizado_em TIMESTAMP DEFAULT NOW()
            );
            """
        ]
        
        # TODO: Executar as queries SQL diretamente via Supabase admin API
        self.log_message('⚠️  Crie as tabelas manualmente no Supabase se necessário')
    
    def parse_csv(self, filepath: str) -> list:
        """Parse CSV file e retorna lista de dicts"""
        items = []
        try:
            # Detecta delimiter
            with open(filepath, 'r', encoding='utf-8') as f:
                sample = f.read(1024)
                delimiter = ';' if ';' in sample else ','
            
            df = pd.read_csv(filepath, sep=delimiter, encoding='utf-8', decimal=',')
            
            # Normaliza nomes de colunas: remove acentos, espaços, caracteres especiais
            def normalize_column(col):
                # Remove acentos usando NFD decomposition
                col_nfd = unicodedata.normalize('NFD', col)
                col_no_accents = ''.join(c for c in col_nfd if unicodedata.category(c) != 'Mn')
                # Converte para minúsculas e substitui espaços/caracteres especiais
                return col_no_accents.lower().strip().replace(' ', '_').replace('-', '_').replace('(', '').replace(')', '').replace('/', '_')
            
            df.columns = [normalize_column(col) for col in df.columns]
            
            items = df.fillna('').to_dict(orient='records')
            self.log_message(f'✅ {filepath}: {len(items)} registros lidos')
        except Exception as e:
            self.log_message(f'❌ Erro ao ler {filepath}: {str(e)}', 'ERROR')
        
        return items
    
    def sync_ativos(self, filepath: str = None):
        """Sincroniza dados de ativos"""
        if not filepath:
            filepath = self._find_csv('ativos')
        
        if not filepath:
            self.log_message('⚠️  Arquivo de ativos não encontrado', 'WARN')
            return
        
        self.log_message(f'📦 Sincronizando ativos de {filepath}...')
        items = self.parse_csv(filepath)
        
        if not items:
            return
        
        try:
            # Colunas esperadas no Supabase
            expected_cols = {
                'dispositivo', 'grupo_de_dispositivo', 'device_id', 'nome', 'sobrenome',
                'motorista_atual', 'horario_de_trabalho', 'atividade_atual', 'in_privacy_mode',
                'ultimos_tipos_da_zona_de_parada', 'hodometro_atual', 'horas_de_motor_atuais',
                'ativo_desde', 'ativo_ate', 'esta_arquivado', 'plano',
                'tipo_de_dispositivo', 'versao_de_firmware', 'numero_de_serie', 'placa',
                'placa_provincia', 'vin', 'zona_horaria', 'comentario_do_dispositivo', 'status_do_download'
            }
            
            # Filtro e conversão de booleanos
            def convert_boolean(val):
                if isinstance(val, bool):
                    return val
                if isinstance(val, str):
                    return val.lower().strip() in ('verdadeiro', 'true', '1', 'sim', 's')
                return False if val == '' else bool(val)
            
            # Filtro e conversão de datas
            def convert_date(val):
                if val == '' or val is None or (isinstance(val, float) and pd.isna(val)):
                    return None
                return val
            
            # Filtra apenas colunas que existem no banco
            filtered_items = []
            for item in items:
                filtered_item = {}
                for k, v in item.items():
                    if k in expected_cols:
                        # Converte booleanos
                        if k in ('in_privacy_mode', 'esta_arquivado'):
                            filtered_item[k] = convert_boolean(v)
                        # Converte datas
                        elif k in ('ativo_desde', 'ativo_ate'):
                            filtered_item[k] = convert_date(v)
                        else:
                            filtered_item[k] = v
                filtered_items.append(filtered_item)
            
            # Insere em batches de 1000
            batch_size = 1000
            for i in range(0, len(filtered_items), batch_size):
                batch = filtered_items[i:i+batch_size]
                try:
                    self.supabase.table('ativos').insert(batch, count='exact').execute()
                    self.log_message(f'✅ Batch {i//batch_size + 1}: {len(batch)} ativos inseridos')
                except Exception as e:
                    # Se falhar com INSERT, tenta UPSERT (ignora duplicatas)
                    try:
                        # Remove duplicatas por dispositivo mantendo primeiro
                        seen = set()
                        unique_batch = []
                        for item in batch:
                            if item.get('dispositivo') not in seen:
                                unique_batch.append(item)
                                seen.add(item.get('dispositivo'))
                        
                        self.supabase.table('ativos').upsert(unique_batch, on_conflict='dispositivo').execute()
                        self.log_message(f'✅ Batch {i//batch_size + 1}: {len(unique_batch)} ativos inseridos (deduplicado)')
                    except Exception as e2:
                        self.log_message(f'❌ Batch {i//batch_size + 1}: Erro mesmo após deduplicação: {str(e2)[:100]}', 'ERROR')
        except Exception as e:
            self.log_message(f'❌ Erro ao sincronizar ativos: {str(e)}', 'ERROR')
    
    def sync_falhas(self, filepath: str = None):
        """Sincroniza dados de falhas"""
        if not filepath:
            filepath = self._find_csv('falha')
        
        if not filepath:
            self.log_message('⚠️  Arquivo de falhas não encontrado', 'WARN')
            return
        
        self.log_message(f'📦 Sincronizando falhas de {filepath}...')
        items = self.parse_csv(filepath)
        
        if not items:
            return
        
        try:
            # Colunas esperadas no Supabase
            expected_cols = {
                'dispositivo', 'grupo_de_dispositivo', 'data',
                'data_de_extincao_do_defeito', 'usuario_que_extinguiu_o_defeito',
                'descricao', 'modo_de_falha', 'fonte', 'controlador', 'codigo'
            }
            
            # Filtra colunas e remove datas vazias
            filtered_items = []
            for item in items:
                filtered_item = {k: (None if v == '' and 'data' in k else v) 
                                for k, v in item.items() if k in expected_cols}
                filtered_items.append(filtered_item)
            
            batch_size = 1000
            for i in range(0, len(filtered_items), batch_size):
                batch = filtered_items[i:i+batch_size]
                self.supabase.table('falhas').upsert(batch).execute()
                self.log_message(f'✅ Batch {i//batch_size + 1}: {len(batch)} falhas inseridas')
        except Exception as e:
            self.log_message(f'❌ Erro ao sincronizar falhas: {str(e)}', 'ERROR')
    
    def sync_usuarios(self, filepath: str = None):
        """Sincroniza dados de usuários"""
        if not filepath:
            filepath = self._find_csv(('usuarios', 'usuario'))
        
        if not filepath:
            self.log_message('⚠️  Arquivo de usuários não encontrado', 'WARN')
            return
        
        self.log_message(f'📦 Sincronizando usuários de {filepath}...')
        items = self.parse_csv(filepath)
        
        if not items:
            return
        
        try:
            # Colunas esperadas no Supabase
            expected_cols = {'nome_completo', 'e_mail', 'grupo', 'designacao', 'cpf'}
            
            # Filtra colunas e limita tamanho de strings
            filtered_items = []
            for item in items:
                filtered_item = {}
                for k, v in item.items():
                    if k in expected_cols:
                        # Limita tamanho: nome_completo (200), e_mail (150), grupo (100), designacao (100), cpf (14)
                        limits = {
                            'nome_completo': 200,
                            'e_mail': 150,
                            'grupo': 100,
                            'designacao': 100,
                            'cpf': 14
                        }
                        max_len = limits.get(k, 100)
                        if isinstance(v, str):
                            filtered_item[k] = v[:max_len]
                        else:
                            filtered_item[k] = v
                filtered_items.append(filtered_item)
            
            batch_size = 1000
            for i in range(0, len(filtered_items), batch_size):
                batch = filtered_items[i:i+batch_size]
                self.supabase.table('usuarios').upsert(batch).execute()
                self.log_message(f'✅ Batch {i//batch_size + 1}: {len(batch)} usuários inseridos')
        except Exception as e:
            self.log_message(f'❌ Erro ao sincronizar usuários: {str(e)}', 'ERROR')
    
    def _find_csv(self, keywords) -> str:
        """Encontra arquivo CSV pela keyword"""
        if isinstance(keywords, str):
            keywords = [keywords]
        
        csv_dir = Path(CSV_FOLDER)
        if not csv_dir.exists():
            return None
        
        for csv_file in csv_dir.glob('*.csv'):
            filename = csv_file.name.lower()
            if any(keyword.lower() in filename for keyword in keywords):
                return str(csv_file)
        
        return None
    
    def run_all_syncs(self):
        """Executa todas as sincronizações"""
        self.log_message('🚀 Iniciando Pipeline Argus...')
        
        self.setup_tables()
        self.sync_ativos()
        self.sync_falhas()
        self.sync_usuarios()
        
        self.log_message('✅ Pipeline concluído!')
        return self.log
    
    def save_log(self):
        """Salva log de execução"""
        log_dir = Path('logs')
        log_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        log_file = log_dir / f'pipeline_{timestamp}.log'
        
        with open(log_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(self.log))
        
        self.log_message(f'📝 Log salvo em {log_file}')

def main():
    try:
        pipeline = ArgusDataPipeline()
        pipeline.run_all_syncs()
        pipeline.save_log()
        sys.exit(0)
    except Exception as e:
        print(f'❌ ERRO FATAL: {str(e)}')
        sys.exit(1)

if __name__ == '__main__':
    main()
