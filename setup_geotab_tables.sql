-- ================================================================
-- GEOTAB → SUPABASE - SETUP SQL
-- Copie TODO este código no SQL Editor do Supabase
-- ================================================================

-- Tabela: Dispositivos (Veículos)
CREATE TABLE IF NOT EXISTS dispositivos_geotab (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    geotab_device_id TEXT UNIQUE NOT NULL,
    nome VARCHAR(255),
    status VARCHAR(100),
    numero_serie VARCHAR(100),
    tipo_dispositivo VARCHAR(100),
    ativo_desde DATE,
    ativo_ate DATE,
    arquivado BOOLEAN DEFAULT FALSE,
    sincronizado_em TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_dispositivos_geotab_id ON dispositivos_geotab(geotab_device_id);
CREATE INDEX idx_dispositivos_sincronizado ON dispositivos_geotab(sincronizado_em DESC);

-- ================================================================
-- Tabela: Registros de Status (GPS, velocidade, etc)
CREATE TABLE IF NOT EXISTS status_records_geotab (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    geotab_id TEXT,
    device_id TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    velocidade_kmh FLOAT,
    direcao FLOAT,
    data_hora TIMESTAMP WITH TIME ZONE,
    odometro_km FLOAT,
    sincronizado_em TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_status_device_id ON status_records_geotab(device_id);
CREATE INDEX idx_status_data_hora ON status_records_geotab(data_hora DESC);
CREATE INDEX idx_status_sincronizado ON status_records_geotab(sincronizado_em DESC);

-- ================================================================
-- Tabela: Falhas do Veículo (Diagnóstico)
CREATE TABLE IF NOT EXISTS falhas_geotab (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    geotab_id TEXT,
    device_id TEXT,
    codigo_falha VARCHAR(50),
    descricao TEXT,
    data_ocorrencia TIMESTAMP WITH TIME ZONE,
    data_limpeza TIMESTAMP WITH TIME ZONE,
    amplitude FLOAT,
    sincronizado_em TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_falhas_device_id ON falhas_geotab(device_id);
CREATE INDEX idx_falhas_data_ocorrencia ON falhas_geotab(data_ocorrencia DESC);
CREATE INDEX idx_falhas_codigo ON falhas_geotab(codigo_falha);

-- ================================================================
-- Tabela: Motoristas
CREATE TABLE IF NOT EXISTS motoristas_geotab (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    geotab_driver_id TEXT UNIQUE NOT NULL,
    nome VARCHAR(255),
    sobrenome VARCHAR(255),
    numero_cnh VARCHAR(50),
    employee_id VARCHAR(100),
    ativo_desde DATE,
    ativo_ate DATE,
    sincronizado_em TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_motoristas_geotab_id ON motoristas_geotab(geotab_driver_id);
CREATE INDEX idx_motoristas_sincronizado ON motoristas_geotab(sincronizado_em DESC);

-- ================================================================
-- Tabela de LOG de Sincronizações (para controle)
CREATE TABLE IF NOT EXISTS geotab_sync_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tipo_sincronizacao VARCHAR(50),
    quantidade_registros INT,
    data_inicio TIMESTAMP WITH TIME ZONE,
    data_fim TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20),
    mensagem_erro TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_sync_log_tipo ON geotab_sync_log(tipo_sincronizacao);
CREATE INDEX idx_sync_log_data ON geotab_sync_log(data_inicio DESC);

-- ================================================================
-- Enable Row Level Security (RLS) para segurança
ALTER TABLE dispositivos_geotab ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_records_geotab ENABLE ROW LEVEL SECURITY;
ALTER TABLE falhas_geotab ENABLE ROW LEVEL SECURITY;
ALTER TABLE motoristas_geotab ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- Policies para permitir leitura pública (ajuste conforme necessário)
CREATE POLICY "Allow public read access" ON dispositivos_geotab
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access" ON status_records_geotab
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access" ON falhas_geotab
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access" ON motoristas_geotab
    FOR SELECT USING (true);

-- ================================================================
-- DONE! ✅
-- Agora você pode executar: python sync_geotab_to_supabase.py
-- ================================================================
