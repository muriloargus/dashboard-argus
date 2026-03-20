# ✅ GIT PUSH SEM INSTALAR NADA NO PC

## Problema: Git não está instalado e você não tem admin

**Solução:** Você tem **3 opções** para fazer git push **SEM instalar nada**:

---

# OPÇÃO 1️⃣: GitHub Web (MAIS FÁCIL - Sem Git)

**Vantagem:** Não precisa de Git. Você só usa o browser.

### Passo 1: Abrir GitHub no browser

```
https://github.com/seu-usuario/seu-repo
```

### Passo 2: Fazer upload dos arquivos

1. Clique no botão **"Add file"** (verde, canto direito)
2. Selecione **"Upload files"**
3. Arraste os arquivos da pasta `Dash - supabase + github` para a janela
4. Clique **"Commit changes"**

**Pronto!** GitHub já fez o commit automaticamente.

GitHub Actions vai rodar sozinho em 2 minutos.

---

# OPÇÃO 2️⃣: RStudio Server (Se você está usando RStudio)

**Você está em RStudio Server?** (Aquela tela que mostraram antes)

RStudio Server **JÁ TEM GIT!**

### Passo 1: Abrir RStudio Server

```
Já deve estar aberto em uma aba do browser
```

### Passo 2: Terminal do RStudio

1. Na RStudio, procure por aba **"Terminal"** (ou **"Console"**)
2. Execute:

```bash
cd /cloud/project
git status
```

### Passo 3: Fazer git push

```bash
git add .
git commit -m "Deploy Shiny"
git push
```

**Pronto!** GitHub Actions vai rodar sozinho.

---

# OPÇÃO 3️⃣: Git Portable (Sem instalar, só descompactar)

Se quiser usar Git no seu PC sem admin:

1. Baixe: https://github.com/git-for-windows/git/releases
2. Procure por **"PortableGit-2.x.x-64-bit.7z.exe"**
3. Descompacte em uma pasta (tipo `C:\git-portable\`)
4. Execute `git.exe` de lá

Mas essa opção é mais complicada.

---

# 🎯 RECOMENDAÇÃO

### Se você está em RStudio Server:
→ **Use OPÇÃO 2** (terminal do RStudio)

### Se está no seu PC local e quer algo simples:
→ **Use OPÇÃO 1** (GitHub Web, arrastar e soltar)

---

## 🚀 QUAL VOCÊ QUER FAZER?

**A) GitHub Web (drag and drop no browser)** - MAIS FÁCIL
- Abir GitHub
- Arrastar arquivos
- Pronto!

**B) RStudio Server (se você está usando)**
- Abir terminal do RStudio
- 3 comandos git
- Pronto!

**Qual você prefere? A ou B?**
