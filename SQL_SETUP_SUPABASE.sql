-- ================================================================
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
