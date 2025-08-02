# 🌐 Debug de Rede - Stacki

## 📋 IPs e Portas Configurados

### **🖥️ VPS Principal**
- **IP:** `31.97.85.98`
- **SSH:** Porta `22`
- **Usuário:** `root`

### **🌐 Portas da Aplicação**

#### **Externa (Internet → VPS)**
- **HTTP:** `80` → Nginx (redirecionamento para HTTPS)
- **HTTPS:** `443` → Nginx → Stacki App
- **SSH:** `22` → Acesso administrativo

#### **Interna (Docker Network)**
- **Stacki App:** `3000` (dentro do container)
- **PostgreSQL:** `5432` (dentro do container)
- **PostgREST:** `3000` (dentro do container postgrest)
- **Nginx:** `80`, `443` (dentro do container nginx)

### **🔗 URLs de Acesso**
- **Principal:** https://www.stacki.com.br
- **Redirect:** https://stacki.com.br → https://www.stacki.com.br
- **Health Check:** https://www.stacki.com.br/health
- **API:** https://www.stacki.com.br/rest/

---

## 🔍 Comandos de Diagnóstico

### **1. Testar Conectividade Básica**
```bash
# Ping para VPS
ping 31.97.85.98

# Testar porta HTTP
curl -I http://31.97.85.98

# Testar porta HTTPS
curl -I https://31.97.85.98

# Testar porta SSH
ssh -o ConnectTimeout=5 root@31.97.85.98 "echo 'SSH OK'"
```

### **2. Testar Resolução DNS**
```bash
# Verificar se domínio resolve
nslookup stacki.com.br
nslookup www.stacki.com.br

# Testar conectividade via domínio
curl -I http://stacki.com.br
curl -I https://www.stacki.com.br
```

### **3. Verificar Serviços na VPS**
```bash
# Conectar na VPS e verificar containers
ssh root@31.97.85.98 "docker ps"

# Verificar portas abertas
ssh root@31.97.85.98 "netstat -tlnp | grep -E ':(80|443|3000|5432)'"

# Status dos serviços
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose ps"
```

### **4. Verificar Logs**
```bash
# Logs do Nginx
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose logs nginx"

# Logs do Stacki
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose logs stacki"

# Logs gerais
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose logs"
```

---

## 🚨 Possíveis Problemas

### **1. Deploy Não Foi Executado**
**Sintoma:** Conexão recusada na porta 80/443
**Diagnóstico:**
```bash
# Verificar se há containers rodando
ssh root@31.97.85.98 "docker ps"
```
**Solução:** Executar deploy manual

### **2. DNS Não Configurado**
**Sintoma:** Domínio não resolve para 31.97.85.98
**Diagnóstico:**
```bash
./verify-domain.sh
```
**Solução:** Configurar registros DNS A

### **3. Firewall Bloqueando**
**Sintoma:** Timeout na conexão
**Diagnóstico:**
```bash
ssh root@31.97.85.98 "ufw status"
```
**Solução:** Abrir portas 80, 443

### **4. SSL Não Configurado**
**Sintoma:** HTTPS não funciona
**Diagnóstico:**
```bash
ssh root@31.97.85.98 "ls -la /opt/stacki/certbot/conf/live/"
```
**Solução:** Executar `./setup-ssl.sh`

### **5. Containers Não Iniciaram**
**Sintoma:** Nginx responde mas app não
**Diagnóstico:**
```bash
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose logs stacki"
```

---

## 🛠 Script de Diagnóstico Rápido

Execute este script para diagnóstico completo:

```bash
#!/bin/bash
echo "🔍 Diagnóstico Stacki - 31.97.85.98"
echo "=================================="

echo "📡 1. Testando conectividade básica..."
ping -c 3 31.97.85.98 || echo "❌ Ping falhou"

echo "🌐 2. Testando portas HTTP/HTTPS..."
curl -m 5 -I http://31.97.85.98 2>/dev/null && echo "✅ HTTP OK" || echo "❌ HTTP falhou"
curl -m 5 -I https://31.97.85.98 2>/dev/null && echo "✅ HTTPS OK" || echo "❌ HTTPS falhou"

echo "🔗 3. Testando domínios..."
curl -m 5 -I http://stacki.com.br 2>/dev/null && echo "✅ stacki.com.br OK" || echo "❌ stacki.com.br falhou"
curl -m 5 -I https://www.stacki.com.br 2>/dev/null && echo "✅ www.stacki.com.br OK" || echo "❌ www.stacki.com.br falhou"

echo "🏥 4. Testando health check..."
curl -m 5 https://www.stacki.com.br/health 2>/dev/null && echo "✅ Health OK" || echo "❌ Health falhou"

echo "🔍 5. Verificando DNS..."
nslookup stacki.com.br | grep -A1 "Name:" || echo "❌ DNS stacki.com.br falhou"
nslookup www.stacki.com.br | grep -A1 "Name:" || echo "❌ DNS www.stacki.com.br falhou"
```

---

## 📞 Diagnóstico Imediato

### **Teste 1: Conectividade VPS**
```bash
curl -I http://31.97.85.98
```
**Esperado:** HTTP/1.1 301 Moved Permanently (redirect para HTTPS)

### **Teste 2: Domínio Principal**
```bash
curl -I https://www.stacki.com.br
```
**Esperado:** HTTP/2 200 (página carrega)

### **Teste 3: Containers Rodando**
```bash
ssh root@31.97.85.98 "docker ps | grep -E '(stacki|nginx|postgres)'"
```
**Esperado:** 3+ containers rodando

---

## 🚀 Soluções Rápidas

### **Se VPS não responde:**
```bash
# Deploy manual forçado
export VPS_PASSWORD="sua_senha"
./deploy-manual.sh
```

### **Se containers não estão rodando:**
```bash
ssh root@31.97.85.98 "cd /opt/stacki && docker-compose up -d"
```

### **Se SSL não funciona:**
```bash
ssh root@31.97.85.98 "cd /opt/stacki && ./setup-ssl.sh"
```

---

## 📊 Status de Debug

Execute os comandos acima e me informe:

1. **🌐 O que retorna:** `curl -I http://31.97.85.98`
2. **🔍 O que retorna:** `curl -I https://www.stacki.com.br`
3. **🐳 Containers rodando:** `ssh root@31.97.85.98 "docker ps"`

Com essas informações posso identificar exatamente onde está o problema! 🔍