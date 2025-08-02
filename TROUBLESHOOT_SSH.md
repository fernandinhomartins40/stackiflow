# 🔧 Troubleshooting SSH - Deploy Falhou

## ❌ Erro Identificado
```
ssh: handshake failed: read tcp 172.17.0.2:57686->31.97.85.98:22: read: connection reset by peer
```

### 🔍 **Análise do Erro:**
- **Connection reset by peer** = VPS rejeitou/fechou a conexão
- **Porta 22** = SSH está sendo acessado
- **172.17.0.2** = IP interno do container GitHub Actions

---

## 🚨 Possíveis Causas

### **1. Firewall/Security Group Bloqueando**
- VPS pode ter firewall restritivo
- Security groups bloqueando GitHub Actions IPs
- Rate limiting por muitas tentativas

### **2. SSH Server Issues**
- SSH daemon não rodando
- SSH configurado para aceitar apenas chaves específicas
- MaxStartups ou MaxSessions limitado

### **3. VPS Sobrecarregada**
- CPU/Memory alta impedindo conexões SSH
- Muitos processos rodando
- Docker containers consumindo recursos

### **4. Rede/Provider Issues**
- Problemas de rede temporários
- Provider VPS com instabilidade
- Latência alta entre GitHub e VPS

---

## 🔧 Soluções Imediatas

### **Solução 1: Verificar Status da VPS**
```bash
# Testar conectividade básica
ping 31.97.85.98

# Testar porta SSH
telnet 31.97.85.98 22
# ou
nc -v 31.97.85.98 22

# Testar SSH manual
ssh root@31.97.85.98
```

### **Solução 2: Deploy Manual (Fallback)**
Se GitHub Actions falhar, use deploy manual:

```bash
# Configurar senha da VPS
export VPS_PASSWORD="sua_senha_vps"

# Executar deploy local
./deploy-manual.sh
```

### **Solução 3: Configurar SSH Key (Recomendado)**
Em vez de senha, usar chave SSH:

```bash
# Gerar chave SSH (se não tiver)
ssh-keygen -t rsa -b 4096 -C "stacki-deploy"

# Copiar chave pública para VPS
ssh-copy-id root@31.97.85.98

# Adicionar chave privada como secret no GitHub
# Settings → Secrets → Actions → New secret
# Nome: SSH_PRIVATE_KEY
# Valor: conteúdo do arquivo ~/.ssh/id_rsa
```

### **Solução 4: Configurar Firewall VPS**
```bash
# Conectar na VPS
ssh root@31.97.85.98

# Verificar firewall
ufw status

# Permitir SSH se bloqueado
ufw allow 22

# Permitir portas da aplicação
ufw allow 80
ufw allow 443
ufw allow 3008
ufw allow 3009
ufw allow 5434
```

---

## 🔄 Workflow Corrigido com SSH Key

Vou atualizar o workflow para usar chave SSH:

```yaml
- name: 🚀 Deploy para VPS
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: 31.97.85.98
    username: root
    key: ${{ secrets.SSH_PRIVATE_KEY }}  # ← Chave em vez de senha
    port: 22
    timeout: 300s  # ← Timeout maior
    command_timeout: 600s  # ← Timeout maior para comandos
```

---

## 📊 Debug Avançado

### **Verificar Logs SSH na VPS:**
```bash
ssh root@31.97.85.98
tail -f /var/log/auth.log
# ou
journalctl -f -u ssh
```

### **Verificar Recursos da VPS:**
```bash
ssh root@31.97.85.98
top
free -h
df -h
systemctl status ssh
```

### **Testar Conectividade GitHub → VPS:**
```bash
# No GitHub Actions, adicionar step de debug:
- name: 🔍 Debug SSH
  run: |
    echo "Testing connectivity..."
    ping -c 3 31.97.85.98 || echo "Ping failed"
    nc -z -v 31.97.85.98 22 || echo "SSH port closed"
    curl -I http://31.97.85.98 || echo "HTTP failed"
```

---

## ⚡ Solução Rápida: Deploy Manual

**Execute agora mesmo:**

```bash
# 1. Configure a senha (substitua pela real)
export VPS_PASSWORD="sua_senha_da_vps"

# 2. Execute o deploy manual
./deploy-manual.sh

# 3. Aguarde o deploy completar
# 4. Teste: http://31.97.85.98:3008
```

---

## 🎯 Próximos Passos

### **Imediato (para resolver agora):**
1. ✅ **Deploy Manual** - Execute `./deploy-manual.sh`
2. ✅ **Testar VPS** - `ssh root@31.97.85.98`
3. ✅ **Verificar firewall** - `ufw status`

### **Longo prazo (para corrigir GitHub Actions):**
1. 🔑 **Configurar SSH Key** em vez de senha
2. 🔧 **Aumentar timeouts** no workflow
3. 🔍 **Adicionar debug** no workflow
4. 🛡️ **Configurar firewall** adequadamente

---

## 📱 Status Atual

- ❌ **GitHub Actions:** Falhando por SSH
- ✅ **Deploy Manual:** Disponível como backup
- ⚠️ **VPS:** Status desconhecido (precisa verificar)
- 🎯 **Target:** http://31.97.85.98:3008

**Execute o deploy manual agora para ter o Stacki funcionando!** 🚀