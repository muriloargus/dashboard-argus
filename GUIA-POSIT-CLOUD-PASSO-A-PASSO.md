# 📚 GUIA PASSO-A-PASSO: POSIT CLOUD + SHINY DASHBOARDS

## ❌ O que VOCÊ FEZ (não vai funcionar)
```
Você colocou um link do GitHub dentro do Posit Cloud
❌ Isso NÃO funciona - Posit Cloud não "lê" links do GitHub assim
```

## ✅ O que VOCÊ DEVERIA FAZER

Tem **2 maneiras corretas**:

---

# 🚀 MANEIRA 1: GitHub Actions (AUTOMÁTICO - Melhor)

Se você tem esse arquivo no GitHub:
```
.github/workflows/deploy-shiny.yml  ✅ (Já foi criado para você)
```

GitHub Actions **automaticamente** faz o deploy para Posit Cloud.

### Passo 1: Configurar secrets no GitHub

1. Acesse seu repositório: **github.com/seu-usuario/seu-repo**
2. Clique em **⚙️ Settings** (no topo, lado direito)
3. Na esquerda, clique **Secrets and variables → Actions**
4. Clique botão verde **New repository secret**

Você precisa adicionar **4 secrets**:

#### 4.1️⃣ PRIMEIRO SECRET: POSIT_ACCOUNT_NAME

```
Name: POSIT_ACCOUNT_NAME
Secret: murilooliveira  (ou seu usuário do Posit Cloud)
```

Clique **Add secret**

#### 4.2️⃣ SEGUNDO SECRET: POSIT_TOKEN

Para pegar o token:

```
1. Acesse https://posit.cloud
2. Clique no seu AVATAR (canto superior direito)
3. Selecione "Tokens"
4. Clique botão "Add Token"
5. Dê um nome: "GitHub Deploy"
6. Copie TUDO que aparecer (vai parecer um código longo)
```

Vai aparecer algo tipo:
```r
rsconnect::setAccountInfo(account='murilooliveira', 
                          token='abc123def456ghi789...', 
                          secret='jkl012mno345pqr678...')
```

Copie só o **token** (a parte `abc123def456ghi789...`):

```
Name: POSIT_TOKEN
Secret: abc123def456ghi789...
```

Clique **Add secret**

#### 4.3️⃣ TERCEIRO SECRET: POSIT_ACCOUNT_ID

No mesmo lugar, você encontrou:
```
Name: POSIT_ACCOUNT_ID
Secret: 12135848  (ou seu ID do Posit Cloud)
```

Clique **Add secret**

#### 4.4️⃣ QUARTO SECRET: POSIT_SECRET

Copie a parte **secret** do token (a parte `jkl012mno345pqr678...`):

```
Name: POSIT_SECRET
Secret: jkl012mno345pqr678...
```

Clique **Add secret**

### Passo 2: Fazer um git push

No VS Code terminal, execute:

```bash
git add .
git commit -m "Deploy shiny dashboards"
git push origin main
```

### Passo 3: GitHub Actions vai fazer TUDO sozinho ✅

1. Vá em: **GitHub → Actions**
2. Procure por **"Deploy Shiny Dashboards"**
3. Espere ficar verde (5-10 minutos)
4. Após terminar, seus 15 dashboards estão online!

### Passo 4: Acessar seus dashboards

Após o GitHub Actions terminar (fica verde), acesse:

```
https://murilooliveira.shinyapps.io/dashboard_menu/
https://murilooliveira.shinyapps.io/dashboard_ativos/
https://murilooliveira.shinyapps.io/dashboard_usuarios/
... etc
```

---

# 📂 MANEIRA 2: Upload Manual (Se GitHub não funcionar)

Se GitHub Actions der problema, faça upload manualmente no Posit Cloud.

### Para CADA dashboard, siga:

#### Passo 1: Ir para Posit Cloud

```
https://posit.cloud
Login
```

#### Passo 2: Fazer upload de UMA pasta

1. Clique no botão **"Publish"** ou **"+"** (alto, no topo)
2. Selecione **"Shiny Application"**
3. Em **"Application Type"**: escolha **"Shiny (R)"**
4. Em **"Files to Deploy"**: selecione a pasta inteira
   - Por exemplo: `shiny/dashboard_menu/`
5. Clique **"Deploy"**
6. Espere 2-3 minutos

#### Passo 3: Detectar o app

Posit Cloud vai:
```
✅ Ler o app.R
✅ Detectar dependências
✅ Fazer build automaticamente
✅ Colocar online
```

#### Passo 4: Repetir para CADA dashboard

Você precisa fazer isso 15 vezes (uma por dashboard):

```
1. dashboard_menu
2. dashboard_ativos
3. dashboard_usuarios
4. dashboard_motoristas
5. dashboard_falhas
6. dashboard_dispositivos
7. dashboard_excecoes
8. dashboard_timeline
9. dashboard_temporal_mapas
10. dashboard_risco_colisao
11. dashboard_desempenho_analista
12. dashboard_comparativo
13. dashboard_ativos_supabase
14. dashboard_falhas_supabase
15. dashboard_usuarios_supabase
```

⏱️ **Tempo total:** ~45 minutos (3 min × 15)

---

# 🎯 QUAL MANEIRA ESCOLHER?

| Critério | GitHub Actions | Upload Manual |
|----------|---|---|
| **Tempo inicial** | 5 min | 45 min |
| **Facilidade** | Muito fácil | Fácil mas repetitivo |
| **Automático depois?** | ✅ Sim (GitHub faz tudo) | ❌ Não (precisa refazer) |
| **Melhor para** | Quem tem Git/GitHub | Quem quer rápido |

### ✅ RECOMENDAÇÃO: **GitHub Actions**

Por que?
1. Setup inicial: 5 minutos
2. Depois: completamente automático
3. Se atualizar dados/código → GitHub Actions redeploy
4. Sem trabalho manual repetitivo

---

# ❓ FAQ: PROBLEMAS COMUNS

## P: "Deploy falhou. O que fazer?"

R: Vá em **GitHub → Actions → Deploy Shiny Dashboards → [última execução] → Logs**

Procure por erros tipo:
```
Error: package 'shiny' not found
```

Se isso acontecer:
1. Verifique se `shiny/dashboard_*/app.R` estão corretos
2. Verifique se tem `require(shiny)` no começo de cada app.R
3. Tente novamente: `git push`

## P: "Posit Cloud diz 'Failed to deploy'. Por quê?"

R: Provavelmente:
- Token expirou → gere um novo token no Posit Cloud
- Secrets estão errados → copie de novo do token
- Pasta vazia → certifique que tem `app.R` dentro

## P: "Meu dashboard diz 'Deployment failed'."

R: No Posit Cloud → clique no dashboard → **Logs**

Procure por erros tipo:
```
Error in library(plotly) - package not found
```

Solução:
1. Vá em `shiny/dashboard_*/app.R`
2. Veja se tem todos os `require()` no início
3. Compare com outro dashboard que funciona
4. Commit e push novamente

## P: "GitHub Actions nunca termina."

R: Abra: **GitHub → Actions → [seu workflow]**

Se tiver erro:
- Secrets faltando → adicione (POSIT_ACCOUNT_NAME, etc)
- Internet caída → espere
- Posit Cloud caído → verifique status.posit.com

## P: "Acessei a URL mas dashboard está em branco."

R: Abra browser **Developer Tools (F12) → Console**

Procure por erros em vermelho tipo:
```
Error: Cannot find module 'plotly'
```

Se sim: Package falta no `app.R`

Solução:
1. Edite `shiny/dashboard_*/app.R`
2. Procure por `require(plotly)` (deve estar lá)
3. Se não tiver → adicione no topo do arquivo
4. Commit, push, GitHub Actions redeploy

---

# 📝 CHECKLIST: O QUE FAZER AGORA

## Opção A: GitHub Actions (RECOMENDADO)

- [ ] Abrir Posit Cloud
- [ ] Clique avatar → Tokens → Add Token → "GitHub Deploy"
- [ ] Copiar os 4 valores do token
- [ ] Ir ao GitHub → Settings → Secrets → Add 4 secrets:
  - [ ] POSIT_ACCOUNT_NAME (seu usuário)
  - [ ] POSIT_TOKEN (token copiado)
  - [ ] POSIT_ACCOUNT_ID (seu ID)
  - [ ] POSIT_SECRET (secret do token)
- [ ] VS Code terminal:
  ```bash
  git add .
  git commit -m "Deploy shiny"
  git push origin main
  ```
- [ ] Aguardar 10 minutos (GitHub Actions rodando)
- [ ] Verificar em: **GitHub → Actions → Deploy Shiny Dashboards**
- [ ] Quando ficar verde ✅, acessar: `https://seu-usuario.shinyapps.io/dashboard_menu/`

## Opção B: Upload Manual

- [ ] Abrir Posit Cloud
- [ ] Para cada uma das 15 pastas em `shiny/dashboard_*`:
  - [ ] Clique Publish
  - [ ] Selecione Shiny Application
  - [ ] Carregue a pasta
  - [ ] Nomeie (dashboard_menu, dashboard_ativos, etc)
  - [ ] Deploy
  - [ ] Aguarde 2-3 min

---

# 🔗 LINKS ÚTEIS

- **Posit Cloud:** https://posit.cloud
- **Token Generator:** https://posit.cloud → Avatar → Tokens
- **Seu espaço:** https://seu-usuario.shinyapps.io
- **GitHub Actions Logs:** GitHub → Actions → Deploy Shiny Dashboards
- **Posit Documentation:** https://docs.posit.co/shinyapps-io/

---

# 💡 DICA FINAL

Se tiver erro:

1. **GitHub Actions deu erro?**
   → Veja logs em GitHub → Actions → [última execução]

2. **Dashboard em branco?**
   → Abra F12 → Console → veja erros em vermelho

3. **Posit Cloud rejeitou deployment?**
   → Clique no dashboard → Logs → veja mensagem de erro

4. **Posit Cloud "Connection Timeout"?**
   → Espere 5 min (Posit está fazendo build)

**Qualquer erro: compartilhe a mensagem e eu ajudo!**
