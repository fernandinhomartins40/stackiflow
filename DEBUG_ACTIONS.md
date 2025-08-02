# 🔍 Debug GitHub Actions - Checklist

## ❌ GitHub Actions não está iniciando automaticamente

### 📋 **Checklist Urgente**

#### ✅ **1. Verificar se Actions está habilitado**
**URL:** https://github.com/fernandinhomartins40/stackiflow/settings/actions

**Configuração necessária:**
- ✅ **Actions permissions:** "Allow all actions and reusable workflows"
- ✅ **Workflow permissions:** "Read and write permissions"
- ✅ **Allow GitHub Actions to create and approve pull requests:** ✅

#### ✅ **2. Verificar arquivo workflow existe**
**URL:** https://github.com/fernandinhomartins40/stackiflow/tree/main/.github/workflows

**Deve mostrar:**
- ✅ `deploy-vps.yml` (2.1 KB)

#### ✅ **3. Verificar tab Actions**
**URL:** https://github.com/fernandinhomartins40/stackiflow/actions

**Possíveis cenários:**
- 🟢 **Workflow rodando:** Verde com spinner
- 🔴 **Workflow falhado:** Vermelho com X
- ⚪ **Nenhum workflow:** Problema de configuração

#### ✅ **4. Verificar Secret configurado**
**URL:** https://github.com/fernandinhomartins40/stackiflow/settings/secrets/actions

**Deve mostrar:**
- ✅ `VPS_PASSWORD` (configurado em [data])

---

## 🚀 **Soluções Imediatas**

### **Solução 1: Trigger Manual**
Se o automático não funcionar, force manualmente:

1. Vá em: https://github.com/fernandinhomartins40/stackiflow/actions
2. Clique em `🚀 Deploy Stacki to VPS` (lado esquerdo)
3. Clique em `Run workflow` (botão azul)
4. Selecione `Branch: main`
5. Clique em `Run workflow`

### **Solução 2: Habilitar Actions**
Se Actions estiver desabilitado:

1. https://github.com/fernandinhomartins40/stackiflow/settings/actions
2. Marcar "Allow all actions and reusable workflows"
3. Salvar configurações
4. Fazer novo commit para trigger

### **Solução 3: Re-trigger com Commit**
Forçar novo trigger:

```bash
# Criar commit vazio para trigger
git commit --allow-empty -m "🔄 Force GitHub Actions trigger"
git push origin main
```

### **Solução 4: Deploy Manual (Fallback)**
Se GitHub Actions não funcionar, execute direto:

```bash
# Configurar senha da VPS
export VPS_PASSWORD="sua_senha_vps"

# Executar deploy manual
./deploy-manual.sh
```

---

## 🔎 **Diagnóstico Detalhado**

### **Verificar sintaxe do workflow:**
```bash
# Verificar se arquivo está correto
cat .github/workflows/deploy-vps.yml | head -10
```

### **Verificar logs no repositório:**
1. Actions → All workflows
2. Verificar se há mensagens de erro
3. Clicar em qualquer workflow falhado

### **Verificar permissões do repositório:**
- Settings → Actions → General
- Workflow permissions deve estar em "Read and write"

---

## 🚨 **Problemas Mais Comuns**

### **1. Actions Desabilitado por Padrão**
**Sintoma:** Tab Actions vazia ou com aviso
**Solução:** Settings → Actions → Allow all actions

### **2. Workflow YAML Inválido**
**Sintoma:** Workflow não aparece na lista
**Solução:** Verificar indentação e sintaxe YAML

### **3. Secret Não Configurado**
**Sintoma:** Workflow falha na etapa SSH
**Solução:** Adicionar VPS_PASSWORD nos secrets

### **4. Permissões Insuficientes**
**Sintoma:** "Permission denied" nos logs
**Solução:** Habilitar "Read and write permissions"

### **5. Branch Incorreta**
**Sintoma:** Push não triggerou workflow
**Solução:** Verificar se push foi para branch `main`

---

## ✅ **Ações Imediatas**

**Ordem de prioridade:**

1. **🔥 URGENTE:** Verificar https://github.com/fernandinhomartins40/stackiflow/settings/actions
2. **📋 VERIFICAR:** https://github.com/fernandinhomartins40/stackiflow/actions
3. **🚀 TESTAR:** Trigger manual do workflow
4. **🔄 FORÇAR:** Commit vazio se necessário
5. **🛠 BACKUP:** Deploy manual como último recurso

---

## 📱 **URLs Importantes**

- **Actions Tab:** https://github.com/fernandinhomartins40/stackiflow/actions
- **Settings Actions:** https://github.com/fernandinhomartins40/stackiflow/settings/actions
- **Secrets:** https://github.com/fernandinhomartins40/stackiflow/settings/secrets/actions
- **Workflow File:** https://github.com/fernandinhomartins40/stackiflow/blob/main/.github/workflows/deploy-vps.yml

---

## 🎯 **Resultado Esperado**

Quando funcionando, você deve ver:

```
🚀 Deploy Stacki to VPS
✅ in progress • fernandinhomartins40 • 2fbea40
```

**O importante é ter o Stacki funcionando! Se GitHub Actions não funcionar, temos o deploy manual como backup.** 🚀