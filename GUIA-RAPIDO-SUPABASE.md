## 🚀 Início Rápido - Supabase + GitHub Automation

**Você já tem as credenciais?** Ótimo! Siga este guia passo a passo.

---

## 📋 O Que Você Ganhou

✅ **Sem mais CSVs em produção**  
✅ **Dados atualizados automaticamente**  
✅ **Sincronização 24/7 com GitHub Actions**  
✅ **Dashboard em tempo real**  
✅ **Armazenamento em banco de dados PostgreSQL**

---

## 🔧 Passo 1: Configurar Supabase (2 minutos)

### 1.1 Acessar o Supabase

https://app.supabase.com → Faça login

### 1.2 Criar Tabelas

1. Clique em "SQL Editor"
2. Cole este código:

```sql
-- Cria tabelas para o Argus Dashboard

CREATE TABLE IF NOT EXISTS ativos (
    id SERIAL PRIMARY KEY,
    dispositivo VARCHAR(50) UNIQUE,
    grupo_dispositivo TEXT,
    nome VARCHAR(100),
    sobrenome VARCHAR(100),
    motorista_atual VARCHAR(100),
    horario_trabalho VARCHAR(50),
    atividade_atual VARCHAR(50),
    odometro_atual FLOAT,
    horas_motor FLOAT,
    placa VARCHAR(50),
    vin VARCHAR(50),
    status_download VARCHAR(100),
    ultima_viagem DATE,
    ultima_comunicacao TIMESTAMP,
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS falhas (
    id SERIAL PRIMARY KEY,
    dispositivo VARCHAR(50),
    data_falha TIMESTAMP,
    descricao TEXT,
    modo_falha VARCHAR(100),
    criado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS excecoes (
    id SERIAL PRIMARY KEY,
    data_evento TIMESTAMP,
    evento VARCHAR(200),
    dispositivo VARCHAR(50),
    motorista VARCHAR(100),
    status VARCHAR(50),
    criado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    usuario_id VARCHAR(50),
    nome VARCHAR(100),
    email VARCHAR(100),
    tipo_usuario VARCHAR(50),
    criado_em TIMESTAMP DEFAULT NOW()
);

-- Habilita acesso público (RLS)
ALTER TABLE ativos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ativos_read" ON ativos FOR SELECT USING (true);

ALTER TABLE falhas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "falhas_read" ON falhas FOR SELECT USING (true);

ALTER TABLE excecoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "excecoes_read" ON excecoes FOR SELECT USING (true);

ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "usuarios_read" ON usuarios FOR SELECT USING (true);
```

3. Execute o SQL

✅ **Pronto!**

---

## 🔐 Passo 2: Obter Chave de Servidor (2 minutos)

1. Vá em **Settings → API**
2. Copie a chave que começa com `eyJh...` (service_role)
3. Guarde em local seguro

---

## 🐙 Passo 3: GitHub Secrets (3 minutos)

1. Acesse: https://github.com/muriloargus/dashboard-argus
2. **Settings → Secrets and variables → Actions**
3. Adicione 3 secrets:

| Nome | Valor |
|------|-------|
| `SUPABASE_URL` | `https://fnlgstkkkxzrszmxqwwf.supabase.co` |
| `SUPABASE_ANON_KEY` | `sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1` |
| `SUPABASE_SERVICE_ROLE_KEY` | (A chave que você copiou acima) |

---

## 💻 Passo 4: Setup Local (5 minutos)

```bash
# Navegue até a pasta do projeto
cd c:\Users\muril\Downloads\dashboard_argus

# Crie arquivo .env
copy .env.example .env

# Abra no editor e preencha:
# SUPABASE_SERVICE_ROLE_KEY=eyJh...
```

**Instale dependências:**

```bash
pip install -r requirements.txt
```

---

## ✅ Passo 5: Sincronização Inicial (5 minutos)

**Importante:** Coloque seus arquivos CSV em `input/` primeiro

```bash
# Crie a pasta input se não existir
mkdir input

# Copie seus CSVs:
# input/ativos*.csv
# input/falhas*.csv
# input/usuarios*.csv
```

**Execute o pipeline:**

```bash
python pipeline.py
```

**Deve aparecer algo como:**
```
[2026-03-02 14:30:15] [INFO] 🚀 Iniciando Pipeline Argus...
[2026-03-02 14:30:15] [INFO] ✅ Ativos (ativos 23-02.csv): 1768 registros lidos
[2026-03-02 14:30:16] [INFO] ✅ Batch 1: 1000 ativos inseridos
```

✅ **Sucesso! Seus dados estão no Supabase**

---

## 🎯 Passo 6: Usar nos Dashboards (3 minutos)

**Abra qualquer dashboard HTML (recomendo o novo):**

```bash
# Abra no navegador:
dashboard_ativos_supabase.html
```

**Ou integre em um dashboard existente:**

```html
<!-- No topo do HTML -->
<script src="supabase-client.js"></script>

<script>
const supabase = initSupabase(
    'https://fnlgstkkkxzrszmxqwwf.supabase.co',
    'sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1'
);

// Busca dados
async function carregar() {
    const ativos = await supabase.getAtivos();
    console.log('Ativos:', ativos);
    
    // Use os dados para renderizar gráficos
}

carregar();
</script>
```

---

## 🔄 Passo 7: Automação (1 minuto)

**GitHub Actions já está configurado para:**

1. ✅ Executar a cada 6 horas automaticamente
2. ✅ Sincronizar quando CSVs são atualizados
3. ✅ Permitir execução manual

**Para disparar manualmente:**

1. Vá em: Actions > "Sincronizar Dados com Supabase"
2. Clique em "Run workflow"

---

## 📊 Resultado Final

```
Seu CSV
  ↓
[GitHub Actions]
  ↓
[Python Pipeline]
  ↓
[Supabase PostgreSQL]  ← Fonte de verdade
  ↓
[JavaScript Client]
  ↓
[Dashboard em Tempo Real] ✨
```

---

## 🎯 Checklist Final

- [ ] Supabase tables criadas
- [ ] GitHub Secrets adicionados
- [ ] `.env` preenchido
- [ ] Primeiro `python pipeline.py` executado com sucesso
- [ ] `dashboard_ativos_supabase.html` mostrando dados
- [ ] GitHub Actions workflow disparado com sucesso
- [ ] CSVs movidos para `input/` folder

---

## 📞 Troubleshooting

### "❌ SUPABASE_SERVICE_ROLE_KEY não configurada"
```bash
# Verifique o .env
cat .env

# A chave deve começar com "eyJh"
```

### "❌ Table does not exist"
```bash
# Volte ao Supabase e execute o SQL novamente
# Verifique em: Table Editor
```

### "❌ Erro 401 Unauthorized"
```bash
# ANON_KEY está errada?
# Copie novamente de: Settings > API > anon (public)
```

### "⚠️ 0 ativos inseridos"
```bash
# Os CSVs estão em input/?
ls input/
# Nomes dos arquivos têm 'ativo' ou 'ativos'?
```

---

## 📚 Próximos Passos

1. **Adaptar mais dashboards** para usar Supabase
2. **Remover dependência de CSVs** completamente
3. **Criar dashboard de administração** para gerenciar dados
4. **Configurar webhooks** do Supabase para notificações

---

## 🚀 Comandos Úteis

```bash
# Ver logs do pipeline
cat logs/pipeline_*.log

# Testar conexão Supabase
python -c "
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_SERVICE_ROLE_KEY'))
print(client.table('ativos').select('count(*)').execute())
"

# Limpar dados antigos
python -c "
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_SERVICE_ROLE_KEY'))
# DELETE FROM ativos WHERE atualizado_em < NOW() - INTERVAL '30 DAYS'
"
```

---

## ✨ Benefícios da Integração

| Antes | Depois |
|-------|--------|
| 📁 CSVs em disco | 🗄️ PostgreSQL em nuvem |
| 🤷 dados desatualizados | 🔄 tempo real |
| 🔄 sincronização manual | ⏰ automática 24/7 |
| 💾 armazenamento local | ☁️ backup automático |
| 🐌 carregamento lento | ⚡ queries otimizadas |

---

**Parabéns! Você agora tem um dashboard moderno, escalável e automatizado!** 🎉

