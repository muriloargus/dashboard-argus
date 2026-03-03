# 🚀 Setup Supabase + GitHub Automation

## ✅ Checklist de Configuração

### 1. Supabase - Criar projeto e tabelas

**Credenciais que você tem:**
```
URL: https://fnlgstkkkxzrszmxqwwf.supabase.co
Chave Pública: sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1
```

**O que fazer:**

1. Acesse: https://app.supabase.com
2. Faça login
3. Vá em "Settings" > "API"
4. Copie a chave **service_role** (não a pública)
5. No Supabase SQL Editor, execute este SQL:

```sql
-- Tabela de Ativos
CREATE TABLE ativos (
    id SERIAL PRIMARY KEY,
    dispositivo VARCHAR(50) UNIQUE,
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

-- Tabela de Falhas
CREATE TABLE falhas (
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

-- Tabela de Exceções
CREATE TABLE excecoes (
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

-- Tabela de Usuários
CREATE TABLE usuarios (
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

-- Habilita RLS (Row Level Security)
ALTER TABLE ativos ENABLE ROW LEVEL SECURITY;
ALTER TABLE falhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE excecoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Políticas públicas (leitura)
CREATE POLICY "ativos_read" ON ativos FOR SELECT USING (true);
CREATE POLICY "falhas_read" ON falhas FOR SELECT USING (true);
CREATE POLICY "excecoes_read" ON excecoes FOR SELECT USING (true);
CREATE POLICY "usuarios_read" ON usuarios FOR SELECT USING (true);
```

---

### 2. GitHub - Configurar Secrets

1. Vá no repositório: https://github.com/muriloargus/dashboard-argus
2. Settings > Secrets and Variables > Actions > New repository secret

Adicione 3 secrets:

| Nome | Valor |
|------|-------|
| `SUPABASE_URL` | `https://fnlgstkkkxzrszmxqwwf.supabase.co` |
| `SUPABASE_ANON_KEY` | `sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1` |
| `SUPABASE_SERVICE_ROLE_KEY` | (Copie da aba "API" do Supabase) |

---

### 3. Preparar repositório local

```bash
# Clone ou navegue para o repositório
cd dashboard_argus

# Crie arquivo .env
cp .env.example .env

# Preencha com suas credenciais
# .env deve ter:
SUPABASE_URL=seu_url
SUPABASE_SERVICE_ROLE_KEY=sua_chave_secreta
SUPABASE_ANON_KEY=sua_chave_publica
CSV_FOLDER=./input
```

---

### 4. Testar local (opcional)

```bash
# Instale dependências
pip install -r requirements.txt

# Execute o pipeline
python pipeline.py
```

---

### 5. Usar nos Dashboards

**No `index.html` ou qualquer dashboard:**

```html
<!-- Inclua o cliente Supabase -->
<script src="supabase-client.js"></script>

<script>
// Inicializa cliente
const supabase = initSupabase(
    'https://fnlgstkkkxzrszmxqwwf.supabase.co',
    'sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1'
);

// Busca dados
async function carregarDados() {
    const ativos = await supabase.getAtivos();
    const falhas = await supabase.getFalhas();
    const exc = await supabase.getExcecoes();
    
    console.log('Ativos:', ativos);
    console.log('Falhas:', falhas);
}

carregarDados();
</script>
```

---

## 📅 Automação

O workflow `.github/workflows/atualizar-dados.yml` executa automaticamente:

- ✅ **A cada 6 horas** (conforme configurado)
- ✅ **Quando arquivos CSV são atualizados**
- ✅ **Manualmente** (via GitHub Actions > Run Workflow)

### Ver logs de execução:

1. Vá em: https://github.com/muriloargus/dashboard-argus/actions
2. Clique em "Sincronizar Dados com Supabase"
3. Veja o status e os logs

---

## 🔄 Fluxo de Dados Atual

```
Seus Dados (CSV)
       ↓
[Pipeline Python]
       ↓
[Supabase PostgreSQL]
       ↓
[JavaScript Client]
       ↓
[Dashboards HTML]
```

---

## 🛠️ Troubleshooting

### Erro: "SUPABASE_SERVICE_ROLE_KEY não configurada"

- [ ] Verifique se a chave foi adicionada aos GitHub Secrets
- [ ] A chave começa com "eyJh..."?

### Erro: "Table does not exist"

- [ ] Execute o SQL acima no Supabase Editor
- [ ] Verifique se as tabelas aparecem em "Table Editor"

### Dados não sincronizam

- [ ] Coloque arquivos CSV em pasta `input/`
- [ ] Execute manualmente: https://github.com/muriloargus/dashboard-argus/actions

### Frontend não carrega dados

- [ ] Console do navegador mostra erro?
- [ ] Verifique se SUPABASE_ANON_KEY está correta
- [ ] Ativos RLS (Row Level Security) habilitado?

---

## 📚 Arquivos criados

```
dashboard_argus/
├── requirements.txt           # Dependências Python
├── pipeline.py               # Script de sincronização
├── supabase-client.js        # Cliente JavaScript
├── .env.example              # Template de variáveis
├── .github/
│   └── workflows/
│       └── atualizar-dados.yml  # Workflow GitHub Actions
└── SETUP-SUPABASE.md         # Este arquivo
```

---

## ✨ Próximos passos

1. [x] Configurar Supabase
2. [x] Criar tabelas
3. [x] Adicionar GitHub Secrets
4. [x] Testar pipeline localmente
5. [ ] Fazer primeiro commit
6. [ ] Disparar workflow manual
7. [ ] Verificar sincronização
8. [ ] Integrar nos dashboards
9. [ ] Remover dependência de CSVs

---

**Dúvidas?** Revise a documentação do Supabase:
- https://supabase.com/docs
- https://supabase.com/docs/guides/api/rest

