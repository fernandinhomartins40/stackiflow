# 📋 Setup do Repositório Stacki

## 🚨 Ação Necessária

O fork do Stacki foi preparado, mas você precisa configurar o repositório GitHub:

---

## 1️⃣ **Criar Repositório no GitHub**

1. Acesse https://github.com/new
2. Nome do repositório: `stackiflow` ou `stacki`
3. Descrição: `🚀 Stacki - Tailwind-Native Visual Website Builder`
4. **Público** (recomendado para open source)
5. **NÃO** inicialize com README (já temos)
6. Clique em "Create repository"

---

## 2️⃣ **Configurar Remote e Push**

Após criar o repositório, execute:

```bash
# Adicionar novo remote (substitua SEU_USUARIO)
git remote add origin https://github.com/SEU_USUARIO/stackiflow.git

# Verificar se foi adicionado
git remote -v

# Fazer push inicial
git push -u origin main
```

**Exemplo:**
```bash
git remote add origin https://github.com/fernandinhomartins40/stackiflow.git
git push -u origin main
```

---

## 3️⃣ **Configurar Secrets para Deploy**

No repositório GitHub criado:

1. Vá em `Settings` → `Secrets and variables` → `Actions`
2. Clique em `New repository secret`
3. Adicione:
   - **Nome:** `VPS_PASSWORD`
   - **Valor:** A senha SSH da VPS (31.97.85.98)

---

## 4️⃣ **Testar Deploy Automático**

Após configurar:

1. Faça qualquer alteração e commit
2. Push para main
3. Verifique em `Actions` se o deploy está rodando
4. Aguarde deploy completar
5. Acesse https://www.stacki.com.br

---

## 5️⃣ **Configurar SSL (Primeira vez)**

Após primeiro deploy:

```bash
# Conectar na VPS
ssh root@31.97.85.98

# Configurar SSL
cd /opt/stacki && ./setup-ssl.sh
```

---

## ✅ **Commit Atual Pronto**

O commit já está preparado com:

- ✅ 18 arquivos adicionados/modificados
- ✅ 2086 linhas de código
- ✅ Documentação completa
- ✅ Deploy automático configurado
- ✅ Domínio stacki.com.br configurado

**Só falta criar o repositório e fazer push!** 🚀

---

## 📋 **Status do Projeto**

```
📦 Stacki v0.1.0
├── 🔧 Fork completo do Webstudio
├── 🎨 Rebranding para Tailwind-native
├── 🚀 Deploy automático (GitHub Actions)
├── 🌐 Domínio stacki.com.br configurado
├── 🔐 SSL automático (Let's Encrypt)
├── 🐳 Docker produção completo
└── 📚 Documentação completa
```

**Próximo:** Criar repo no GitHub e fazer push! 🎯