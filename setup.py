#!/usr/bin/env python3
"""
🚀 SETUP AUTOMÁTICO - Argus Dashboard + Supabase
Executa TODO o processo de configuração automaticamente
"""

import os
import sys
import subprocess
from pathlib import Path
from dotenv import load_dotenv

print("""
╔════════════════════════════════════════════════════════════╗
║  🚀 ARGUS DASHBOARD - SETUP AUTOMÁTICO                    ║
║  Configurando Supabase + GitHub para você                 ║
╚════════════════════════════════════════════════════════════╝
""")

# Configuração simplificada - COPIE E COLE SEUS VALORES
SUPABASE_CONFIG = {
    'url': 'https://fnlgstkkkxzrszmxqwwf.supabase.co',
    'anon_key': 'sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1',
    'service_role_key': '',  # Será preenchido depois
}

GITHUB_CONFIG = {
    'repository': 'https://github.com/muriloargus/dashboard-argus',
    'owner': 'muriloargus',
    'repo': 'dashboard-argus'
}

def criar_env_file():
    """Cria arquivo .env com as credenciais"""
    print("\n📝 Passo 1: Criando arquivo .env...")
    
    env_content = f"""# ======================================
# ARGUS DASHBOARD - CONFIGURAÇÃO
# ======================================

# Supabase
SUPABASE_URL={SUPABASE_CONFIG['url']}
SUPABASE_ANON_KEY={SUPABASE_CONFIG['anon_key']}
SUPABASE_SERVICE_ROLE_KEY=COPIE_SUA_CHAVE_SERVICE_ROLE_AQUI

# GitHub
GITHUB_REPOSITORY={GITHUB_CONFIG['repository']}

# Pipeline
CSV_FOLDER=./input
LOG_FOLDER=./logs

# ======================================
# ⚠️ IMPORTANTE:
# 1. Abra o arquivo .env
# 2. Substitua COPIE_SUA_CHAVE_SERVICE_ROLE_AQUI 
#    pela chave do Supabase (começa com eyJh...)
# ======================================
"""
    
    with open('.env', 'w', encoding='utf-8') as f:
        f.write(env_content)
    
    print("✅ .env criado!")
    return True

def criar_sql_setup():
    """Cria arquivo SQL para copiar e colar no Supabase"""
    print("\n📝 Passo 2: Criando arquivo SQL para Supabase...")
    
    sql_content = """-- ================================================================
-- ARGUS DASHBOARD - SQL SETUP
-- Copie este código inteiro e execute no Supabase SQL Editor
-- ================================================================

-- Criar tabela ATIVOS
CREATE TABLE IF NOT EXISTS ativos (
    id BIGSERIAL PRIMARY KEY,
    dispositivo VARCHAR(50) UNIQUE NOT NULL,
    grupo_dispositivo TEXT,
    device_id VARCHAR(50),
    nome VARCHAR(100),
    sobrenome VARCHAR(100),
    motorista_atual VARCHAR(100),
    horario_trabalho VARCHAR(50),
    atividade_atual VARCHAR(50),
    privacy_mode BOOLEAN DEFAULT FALSE,
    endereco_parada TEXT,
    odometro_atual FLOAT,
    horas_motor FLOAT,
    ativo_desde DATE,
    ativo_ate DATE,
    arquivado BOOLEAN DEFAULT FALSE,
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

-- Criar tabela FALHAS
CREATE TABLE IF NOT EXISTS falhas (
    id BIGSERIAL PRIMARY KEY,
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

-- Criar tabela EXCEÇÕES
CREATE TABLE IF NOT EXISTS excecoes (
    id BIGSERIAL PRIMARY KEY,
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

-- Criar tabela USUÁRIOS
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    usuario_id VARCHAR(50),
    nome VARCHAR(100),
    email VARCHAR(100),
    tipo_usuario VARCHAR(50),
    departamento VARCHAR(100),
    status VARCHAR(50),
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security) - Padrão Supabase
ALTER TABLE ativos ENABLE ROW LEVEL SECURITY;
ALTER TABLE falhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE excecoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Criar políticas públicas de leitura
CREATE POLICY "ativos_read_policy" ON ativos FOR SELECT USING (true);
CREATE POLICY "falhas_read_policy" ON falhas FOR SELECT USING (true);
CREATE POLICY "excecoes_read_policy" ON excecoes FOR SELECT USING (true);
CREATE POLICY "usuarios_read_policy" ON usuarios FOR SELECT USING (true);

-- Criar índices para performance
CREATE INDEX idx_ativos_dispositivo ON ativos(dispositivo);
CREATE INDEX idx_ativos_status ON ativos(status_download);
CREATE INDEX idx_falhas_dispositivo ON falhas(dispositivo);
CREATE INDEX idx_falhas_data ON falhas(data_falha);
CREATE INDEX idx_excecoes_dispositivo ON excecoes(dispositivo);
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- ================================================================
-- ✅ PRONTO! As tabelas foram criadas com sucesso
-- ================================================================
"""
    
    with open('SQL_SETUP_SUPABASE.sql', 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print("✅ SQL_SETUP_SUPABASE.sql criado!")
    print("\n📋 PRÓXIMO PASSO:")
    print("1. Abra: https://app.supabase.com")
    print("2. Faça login")
    print("3. Vá em SQL Editor")
    print("4. Abra arquivo: SQL_SETUP_SUPABASE.sql")
    print("5. Copie TUDO e execute no Supabase")
    
    return True

def criar_github_secrets_guide():
    """Cria guia para configurar secrets no GitHub"""
    print("\n📝 Passo 3: Criando guia de GitHub Secrets...")
    
    guide = """# ================================================================
# GITHUB SECRETS - PASSO A PASSO
# ================================================================

## O QUE FAZER:

1. Abra seu repositório GitHub:
   https://github.com/muriloargus/dashboard-argus

2. Clique em Settings (no topo)

3. Na barra lateral, clique em:
   "Secrets and variables" → "Actions"

4. Clique no botão "New repository secret"

5. Adicione CADA UM dos secrets abaixo:

## SECRET 1: SUPABASE_URL
- Name: SUPABASE_URL
- Secret: https://fnlgstkkkxzrszmxqwwf.supabase.co
- Clique "Add secret"

## SECRET 2: SUPABASE_ANON_KEY  
- Name: SUPABASE_ANON_KEY
- Secret: sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1
- Clique "Add secret"

## SECRET 3: SUPABASE_SERVICE_ROLE_KEY
- Name: SUPABASE_SERVICE_ROLE_KEY
- Secret: (COPIE DA SUPABASE - veja instruções abaixo)
- Clique "Add secret"

## COMO OBTER SUPABASE_SERVICE_ROLE_KEY:

1. Abra: https://app.supabase.com
2. Selecione seu projeto
3. Clique em Settings (engrenagem no rodapé)
4. Clique em API
5. Procure por "service_role" 
6. Copie a chave completa (começa com eyJh...)
7. Cole no GitHub secret

## ✅ PRONTO!

Seus 3 secrets devem estar visíveis em:
https://github.com/muriloargus/dashboard-argus/settings/secrets/actions

"""
    
    with open('GITHUB_SECRETS_GUIDE.txt', 'w', encoding='utf-8') as f:
        f.write(guide)
    
    print("✅ GITHUB_SECRETS_GUIDE.txt criado!")
    print("\n📋 INSTRUÇÕES SALVAS EM: GITHUB_SECRETS_GUIDE.txt")

def criar_input_folder():
    """Cria pasta input para CSVs"""
    print("\n📁 Passo 4: Criando pasta para arquivos CSV...")
    
    Path('input').mkdir(exist_ok=True)
    Path('logs').mkdir(exist_ok=True)
    
    print("✅ Pastas criadas!")

def instalar_dependencias():
    """Instala dependências Python"""
    print("\n📦 Passo 5: Instalando dependências Python...")
    print("(Pode levar alguns minutos...)\n")
    
    try:
        subprocess.check_call([
            sys.executable, '-m', 'pip', 'install', 
            '-q', '-r', 'requirements.txt'
        ])
        print("✅ Dependências instaladas!")
        return True
    except Exception as e:
        print(f"⚠️ Erro ao instalar: {e}")
        print("Tente manualmente: pip install -r requirements.txt")
        return False

def exibir_resumo():
    """Exibe resumo final"""
    print("""
╔════════════════════════════════════════════════════════════╗
║  ✅ SETUP QUASE COMPLETO!                                 ║
╚════════════════════════════════════════════════════════════╝

📋 ARQUIVOS CRIADOS:
✅ .env - Suas credenciais (edite com a chave do Supabase)
✅ SQL_SETUP_SUPABASE.sql - SQL para copiar/colar
✅ GITHUB_SECRETS_GUIDE.txt - Instruções do GitHub
✅ input/ - Pasta para seus CSVs
✅ logs/ - Pasta para logs

═══════════════════════════════════════════════════════════════

🎯 PRÓXIMOS PASSOS (5 MINUTOS):

1️⃣ Configure Supabase:
   □ Abra: https://app.supabase.com
   □ Abra o arquivo: SQL_SETUP_SUPABASE.sql
   □ Copie TODO o código
   □ Vá em SQL Editor no Supabase
   □ Cole e execute

2️⃣ Configure GitHub Secrets:
   □ Abra arquivo: GITHUB_SECRETS_GUIDE.txt
   □ Siga cada passo
   □ Adicione 3 secrets

3️⃣ Obtenha sua chave service_role:
   □ Em Supabase, vá em Settings > API
   □ Procure por "service_role" 
   □ Copie a chave (começa com eyJh...)

4️⃣ Edite o arquivo .env:
   □ Abra: .env
   □ Procure por: COPIE_SUA_CHAVE_SERVICE_ROLE_AQUI
   □ Cole sua chave service_role

5️⃣ Adicione seus CSVs:
   □ Coloque seus arquivos CSV em pasta: input/
   □ Nomes devem conter: ativos, falhas, usuarios

6️⃣ Execute o pipeline:
   □ Abra terminal
   □ Digite: python pipeline.py
   □ Espere até aparecer: ✅ Pipeline concluído!

═══════════════════════════════════════════════════════════════

📚 ARQUIVOS DE AJUDA:
- GUIA-RAPIDO-SUPABASE.md (instruções detalhadas)
- SETUP-SUPABASE.md (referência técnica)

🚀 DEPOIS DE TUDO:
- Seus dados estarão no Supabase
- Dashboard funcionará em tempo real
- GitHub Actions rodará a cada 6 horas automaticamente

═══════════════════════════════════════════════════════════════

❓ DÚVIDAS?

Se receber erro "SUPABASE_SERVICE_ROLE_KEY não configurada":
  → Você esqueceu de editar o .env
  → Cole a chave no lugar correto

Se receber erro "Table does not exist":
  → O SQL não foi executado no Supabase
  → Execute o SQL_SETUP_SUPABASE.sql novamente

Se nenhum dado foi importado:
  → Os CSVs estão em pasta input/?
  → Os nomes dos arquivos contêm 'ativos', 'falhas'?

═══════════════════════════════════════════════════════════════
""")

def main():
    try:
        criar_env_file()
        criar_sql_setup()
        criar_github_secrets_guide()
        criar_input_folder()
        instalar_dependencias()
        exibir_resumo()
        
        print("\n✨ SETUP CONCLUÍDO!")
        print("\n📖 Leia os arquivos criados para continuar.\n")
        
    except Exception as e:
        print(f"\n❌ ERRO: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main()
