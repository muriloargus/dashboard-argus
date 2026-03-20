# ✅ GITHUB ACTIONS - SETUP COMPLETO

## 🎯 O que você vai fazer

GitHub Actions vai **automaticamente** fazer deploy de todos os 15 dashboards no Posit Cloud.

**Tempo total:** 10 minutos

---

## PASSO 1️⃣: Gerar Token no Posit Cloud

**Abra em seu browser:** https://posit.cloud

1. Faça **login**
2. Clique no seu **avatar** (canto superior direito)
3. Procure por um menu com opções
4. Procure por: **"Profile Settings"**, **"Account"**, ou **"Security"**

### Se achou menu de Tokens:
- Clique **"Add Token"** ou **"New Token"**
- Nomeie: `GitHub Deploy`
- Copie TUDO que aparecer

Vai parecer assim:
```r
rsconnect::setAccountInfo(account='murilooliveira', 
                          token='abc123def456ghi789jkl012mno345', 
                          secret='pqr678stu901vwx234yz567abc890def')
```

**Copie e guarde esses 3 valores:**
- `account` = murilooliveira (seu usuário)
- `token` = abc123def456ghi789jkl012mno345
- `secret` = pqr678stu901vwx234yz567abc890def

---

## PASSO 2️⃣: Adicionar Secrets no GitHub

**Abra em outro browser:** https://github.com/seu-usuario/seu-repo

Você precisa estar logado no GitHub.

### Ir para Secrets:

1. Clique em **⚙️ Settings** (topo direito do repositório)
2. Na esquerda, clique em **"Secrets and variables"**
3. Clique em **"Actions"**
4. Você vai ver botão verde **"New repository secret"**

---

## PASSO 3️⃣: Criar 3 Secrets

Você vai criar **3 secrets** com os valores que copiou:

### Secret 1️⃣: POSIT_ACCOUNT_NAME

Clique **"New repository secret"**

```
Name: POSIT_ACCOUNT_NAME
Secret: murilooliveira
```

Clique **"Add secret"**

---

### Secret 2️⃣: POSIT_TOKEN

Clique **"New repository secret"** novamente

```
Name: POSIT_TOKEN
Secret: abc123def456ghi789jkl012mno345
```

Clique **"Add secret"**

---

### Secret 3️⃣: POSIT_SECRET

Clique **"New repository secret"** novamente

```
Name: POSIT_SECRET
Secret: pqr678stu901vwx234yz567abc890def
```

Clique **"Add secret"**

---

## PASSO 4️⃣: Fazer um Git Push

No seu **PC local** (VS Code terminal), execute:

```bash
git add .
git commit -m "Add GitHub Actions secrets"
git push origin main
```

---

## PASSO 5️⃣: GitHub Actions vai rodar automaticamente ✅

1. Acesse: **https://github.com/seu-usuario/seu-repo**
2. Clique na aba **"Actions"** (topo do repositório)
3. Você vai ver um workflow **"Deploy Shiny Dashboards"** rodando

### Aguarde até ficar **verde ✅** (5-10 minutos)

---

## PASSO 6️⃣: Seus dashboards estão ONLINE! 🎉

Após GitHub Actions terminar (fica verde), acesse:

```
https://murilooliveira.shinyapps.io/dashboard_menu/
https://murilooliveira.shinyapps.io/dashboard_ativos/
https://murilooliveira.shinyapps.io/dashboard_usuarios/
https://murilooliveira.shinyapps.io/dashboard_motoristas/
https://murilooliveira.shinyapps.io/dashboard_falhas/
https://murilooliveira.shinyapps.io/dashboard_dispositivos/
https://murilooliveira.shinyapps.io/dashboard_excecoes/
https://murilooliveira.shinyapps.io/dashboard_timeline/
https://murilooliveira.shinyapps.io/dashboard_temporal_mapas/
https://murilooliveira.shinyapps.io/dashboard_risco_colisao/
https://murilooliveira.shinyapps.io/dashboard_desempenho_analista/
https://murilooliveira.shinyapps.io/dashboard_comparativo/
https://murilooliveira.shinyapps.io/dashboard_ativos_supabase/
https://murilooliveira.shinyapps.io/dashboard_falhas_supabase/
https://murilooliveira.shinyapps.io/dashboard_usuarios_supabase/
```

(Substitua `murilooliveira` pelo seu usuário do Posit Cloud)

---

## ❓ FAQ

### P: Não achei "Tokens" no Posit Cloud

R: Tenta procurar em:
- **Avatar → Account Settings**
- **Avatar → Security**
- **Avatar → Profile**
- **Settings** (se tiver)

Se ainda não achar, abra: https://posit.cloud/content/

Procure por um ícone de **chave/lock** ou **configurações**.

### P: GitHub Actions deu erro

R: Clique em **Actions → Deploy Shiny Dashboards → [última execução] → Logs**

Procure pela mensagem de erro. Pode ser:

1. **"Secret not found"** → Você não adicionou o secret corretamente
   - Volte no GitHub → Settings → Secrets
   - Verifique nomes: `POSIT_ACCOUNT_NAME`, `POSIT_TOKEN`, `POSIT_SECRET`

2. **"Authentication failed"** → Token expirou
   - Gere um novo token no Posit Cloud
   - Atualize o secret no GitHub

3. **"Package not found"** → Falta dependência
   - Verifique os `require()` nos app.R

### P: GitHub Actions rodou (verde) mas dashboard tá em branco

R: Dashboard está construindo. Espere 5 minutos e recarregue.

---

## 📝 CHECKLIST

- [ ] Abrir https://posit.cloud
- [ ] Gerar token
- [ ] Copiar valores (account, token, secret)
- [ ] Ir para GitHub Settings → Secrets
- [ ] Criar 3 secrets
- [ ] `git push` no VS Code
- [ ] Aguardar GitHub Actions (fica verde)
- [ ] Acessar dashboard em `https://seu-usuario.shinyapps.io/dashboard_menu/`
- [ ] ✅ Sucesso!

---

## 🚀 Pronto!

Depois disso, GitHub Actions roda **automaticamente** toda vez que você fazer:

```bash
git push
```

Se atualizar dados, cores, títulos nos app.R → push → GitHub Actions redeploy automaticamente em 10 minutos.

**Você não precisa fazer nada mais!** 🎉
