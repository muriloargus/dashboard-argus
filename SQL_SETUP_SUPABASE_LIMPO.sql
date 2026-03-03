-- ================================================================
-- ARGUS DASHBOARD - SQL SETUP (VERSÃO LIMPA)
-- Mata tudo e recria do zero com nomes corretos
-- ================================================================

-- 🗑️  LIMPAR TUDO PRIMEIRO (drop com CASCADE)
DROP POLICY IF EXISTS "usuarios_read_policy" ON usuarios;
DROP POLICY IF EXISTS "excecoes_read_policy" ON excecoes;
DROP POLICY IF EXISTS "falhas_read_policy" ON falhas;
DROP POLICY IF EXISTS "ativos_read_policy" ON ativos;

DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS excecoes CASCADE;
DROP TABLE IF EXISTS falhas CASCADE;
DROP TABLE IF EXISTS ativos CASCADE;

-- ================================================================
-- ✨ CRIAR TABELAS COM NOMES CORRETOS
-- ================================================================

-- Criar tabela ATIVOS
CREATE TABLE ativos (
    id BIGSERIAL PRIMARY KEY,
    dispositivo VARCHAR(50) UNIQUE NOT NULL,
    grupo_de_dispositivo TEXT,
    device_id VARCHAR(50),
    nome VARCHAR(100),
    sobrenome VARCHAR(100),
    motorista_atual VARCHAR(100),
    horario_de_trabalho VARCHAR(50),
    atividade_atual VARCHAR(50),
    in_privacy_mode BOOLEAN DEFAULT FALSE,
    ultimos_tipos_da_zona_de_parada TEXT,
    hodometro_atual FLOAT,
    horas_de_motor_atuais FLOAT,
    ativo_desde DATE,
    ativo_ate DATE,
    esta_arquivado BOOLEAN DEFAULT FALSE,
    plano VARCHAR(200),
    tipo_de_dispositivo VARCHAR(100),
    versao_de_firmware VARCHAR(50),
    numero_de_serie VARCHAR(50),
    placa VARCHAR(50),
    placa_provincia TEXT,
    vin VARCHAR(50),
    zona_horaria VARCHAR(50),
    comentario_do_dispositivo TEXT,
    status_do_download VARCHAR(100),
    ultima_viagem DATE,
    ultima_data_de_comunicacao TIMESTAMP,
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- Criar tabela FALHAS
CREATE TABLE falhas (
    id BIGSERIAL PRIMARY KEY,
    dispositivo VARCHAR(50),
    grupo_de_dispositivo TEXT,
    data DATE,
    data_de_extincao_do_defeito TIMESTAMP,
    usuario_que_extinguiu_o_defeito VARCHAR(100),
    descricao TEXT,
    modo_de_falha VARCHAR(100),
    fonte VARCHAR(100),
    controlador VARCHAR(100),
    codigo VARCHAR(50),
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- Criar tabela EXCEÇÕES
CREATE TABLE excecoes (
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
CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    nome_completo VARCHAR(200),
    e_mail VARCHAR(150),
    grupo VARCHAR(100),
    designacao VARCHAR(100),
    cpf VARCHAR(14),
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

-- ================================================================
-- 🔒 HABILITAR RLS (Row Level Security)
-- ================================================================

ALTER TABLE ativos ENABLE ROW LEVEL SECURITY;
ALTER TABLE falhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE excecoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- 📖 CRIAR POLÍTICAS DE LEITURA PÚBLICA
-- ================================================================

CREATE POLICY "ativos_read_policy" ON ativos FOR SELECT USING (true);
CREATE POLICY "falhas_read_policy" ON falhas FOR SELECT USING (true);
CREATE POLICY "excecoes_read_policy" ON excecoes FOR SELECT USING (true);
CREATE POLICY "usuarios_read_policy" ON usuarios FOR SELECT USING (true);

-- ================================================================
-- ⚡ CRIAR ÍNDICES PARA PERFORMANCE
-- ================================================================

CREATE INDEX idx_ativos_dispositivo ON ativos(dispositivo);
CREATE INDEX idx_ativos_status ON ativos(status_do_download);
CREATE INDEX idx_falhas_dispositivo ON falhas(dispositivo);
CREATE INDEX idx_falhas_data ON falhas(data);
CREATE INDEX idx_excecoes_dispositivo ON excecoes(dispositivo);
CREATE INDEX idx_usuarios_email ON usuarios(e_mail);

-- ================================================================
-- ✅ PRONTO!
-- Agora execute no PowerShell:
--    python pipeline.py
-- ================================================================
