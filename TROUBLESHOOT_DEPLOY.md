# 🔍 Troubleshooting - Deploy Automático

## ❌ Problema: Deploy não iniciou automaticamente após push

### 📋 **Checklist de Diagnóstico**

#### ✅ **1. Verificar se o push foi bem-sucedido**
```bash
# Verificar se o commit chegou no GitHub
git log --oneline -5

# Verificar remote configurado
git remote -v

# Verificar se está na branch main
git branch -a
```

#### ✅ **2. Verificar estrutura do arquivo GitHub Actions**
Confirmar se o arquivo está no local correto:
```
.github/
└── workflows/
    └── deploy-vps.yml
```

#### ✅ **3. Verificar configuração do GitHub Actions**

**No repositório GitHub:**
1. Vá em `Settings` → `Actions` → `General`
2. Verificar se "Actions permissions" está habilitado:
   - ✅ **Allow all actions and reusable workflows**
   - ❌ ~~Disable actions~~

#### ✅ **4. Verificar Secret VPS_PASSWORD**

**No repositório GitHub:**
1. `Settings` → `Secrets and variables` → `Actions`
2. Confirmar se existe:
   - **Nome:** `VPS_PASSWORD`
   - **Valor:** [configurado]

#### ✅ **5. Verificar triggers do workflow**

Nosso workflow está configurado para:
```yaml
on:
  push:
    branches: [ main ]      # ← Push para main
  pull_request:
    branches: [ main ]      # ← PR para main
  workflow_dispatch:        # ← Trigger manual
```

---

## 🔧 **Soluções Possíveis**

### **Solução 1: Trigger Manual**
Se o automático falhou, force manualmente:

1. No GitHub: `Actions` → `🚀 Deploy Stacki to VPS`
2. Clique em `Run workflow`
3. Selecione branch `main`
4. Clique em `Run workflow`

### **Solução 2: Verificar Sintaxe YAML**
Possível erro de sintaxe no workflow:

```bash
# Verificar se o arquivo está bem formado
cat .github/workflows/deploy-vps.yml | head -20
```

### **Solução 3: Re-push Forçado**
```bash
# Fazer um pequeno commit para reativar
echo "# Trigger deploy" >> README.md
git add README.md
git commit -m "🔄 Trigger deploy workflow"
git push origin main
```

### **Solução 4: Verificar Logs no GitHub**
1. Ir em `Actions` no repositório
2. Ver se há workflows falhados
3. Verificar mensagens de erro

---

## 🚨 **Problemas Comuns**

### **1. Actions Desabilitado**
**Sintoma:** Nenhum workflow aparece
**Solução:** Habilitar em Settings → Actions

### **2. Secret Não Configurado**
**Sintoma:** Workflow falha na etapa SSH
**Solução:** Adicionar `VPS_PASSWORD` nos secrets

### **3. Sintaxe YAML Inválida**
**Sintoma:** Workflow não aparece ou falha imediatamente
**Solução:** Validar YAML e corrigir indentação

### **4. Permissões Insuficientes**
**Sintoma:** "Permission denied" no workflow
**Solução:** Verificar permissões do repositório

### **5. Branch Incorreta**
**Sintoma:** Push para outra branch não ativa workflow
**Solução:** Fazer push para `main`

---

## 🛠 **Deploy Manual Alternativo**

Se o automático falhar, use o script manual:

```bash
# Configurar senha da VPS
export VPS_PASSWORD="sua_senha_aqui"

# Executar deploy manual
./deploy-manual.sh
```

---

## 📊 **Status Esperado no GitHub Actions**

Quando funcionando corretamente, você deve ver:

```
Actions
├── 🚀 Deploy Stacki to VPS
│   ├── ✅ 📥 Checkout código
│   ├── ✅ 🔧 Setup Node.js
│   ├── ✅ 📦 Setup pnpm
│   ├── ✅ 📦 Instalar dependências
│   ├── ✅ 🏗️ Build aplicação
│   ├── ✅ 📋 Preparar arquivos para deploy
│   ├── ✅ 🚀 Deploy para VPS
│   ├── ✅ 📤 Upload arquivos para VPS
│   ├── ✅ 🔧 Configurar e iniciar aplicação
│   └── ✅ ✅ Notificar sucesso
```

---

## 🔄 **Forçar Deploy Agora**

**Opção 1: GitHub Actions (Recomendado)**
1. GitHub → Actions → Run workflow → main

**Opção 2: Script Manual**
```bash
export VPS_PASSWORD="sua_senha"
./deploy-manual.sh
```

**Opção 3: Re-trigger com Commit**
```bash
git commit --allow-empty -m "🔄 Force deploy trigger"
git push origin main
```

---

## 📞 **Next Steps**

1. ✅ Verificar Settings → Actions habilitado
2. ✅ Confirmar secret VPS_PASSWORD configurado  
3. ✅ Trigger manual se necessário
4. ✅ Verificar logs para erros específicos
5. ✅ Usar deploy manual como fallback

**O importante é ter o Stacki rodando! 🚀**