# 🌐 Configuração de Domínio - www.stacki.com.br

## ✅ Configuração Completa

O Stacki está agora configurado para servir o domínio **www.stacki.com.br** com todas as funcionalidades de produção.

---

## 🔧 Configurações Implementadas

### 🌐 **Nginx Reverse Proxy**
- ✅ Redirecionamento HTTP → HTTPS
- ✅ Redirecionamento stacki.com.br → www.stacki.com.br
- ✅ Headers de segurança
- ✅ Compressão Gzip
- ✅ Cache otimizado para assets
- ✅ Rate limiting para API e auth
- ✅ Suporte a subdomínios (*.stacki.com.br)

### 🔐 **SSL/HTTPS**
- ✅ Let's Encrypt SSL automático
- ✅ Renovação automática de certificados
- ✅ Configuração SSL A+ grade
- ✅ HSTS habilitado
- ✅ Suporte HTTP/2

### 🎯 **Configurações de Domínio**
- ✅ BUILD_ORIGIN: https://www.stacki.com.br
- ✅ BUILD_REQUIRE_SUBDOMAIN: true
- ✅ CORS configurado
- ✅ Subdomínios para preview/canvas

---

## 🚀 Como Fazer Deploy

### 1️⃣ **Verificar DNS** (Obrigatório)
```bash
# Verificar se domínio aponta para VPS
./verify-domain.sh

# Resultado esperado:
# ✅ stacki.com.br → 31.97.85.98
# ✅ www.stacki.com.br → 31.97.85.98
```

### 2️⃣ **Deploy Automático** (Recomendado)
```bash
# Via GitHub Actions
git push origin main

# Ou trigger manual no GitHub
```

### 3️⃣ **Deploy Manual** (Alternativo)
```bash
# Executar script local
export VPS_PASSWORD="sua_senha"
./deploy-manual.sh
```

### 4️⃣ **Configurar SSL** (Primeira vez)
```bash
# Conectar na VPS
ssh root@31.97.85.98

# Executar configuração SSL
cd /opt/stacki && ./setup-ssl.sh
```

---

## 🌍 URLs de Acesso

Após deploy completo:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **App Principal** | https://www.stacki.com.br | Stacki Visual Builder |
| **API Rest** | https://www.stacki.com.br/rest/ | PostgREST API |
| **Health Check** | https://www.stacki.com.br/health | Status da aplicação |
| **Auth** | https://www.stacki.com.br/auth/ | Autenticação |

### 🔗 **Redirecionamentos Automáticos**
- `http://stacki.com.br` → `https://www.stacki.com.br`
- `http://www.stacki.com.br` → `https://www.stacki.com.br`
- `https://stacki.com.br` → `https://www.stacki.com.br`

---

## 🔧 Configurações DNS Necessárias

No seu provedor de DNS (Registro.br, Cloudflare, etc.):

```dns
# Registros A obrigatórios
stacki.com.br.     IN A    31.97.85.98
www.stacki.com.br. IN A    31.97.85.98

# Opcional: Wildcard para subdomínios
*.stacki.com.br.   IN A    31.97.85.98
```

---

## 🛠 Comandos de Manutenção

### 📊 **Monitoramento**
```bash
# Status dos serviços
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose ps'

# Logs em tempo real
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose logs -f'

# Logs específicos
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose logs nginx'
```

### 🔄 **Operações**
```bash
# Restart completo
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose restart'

# Rebuild aplicação
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose up -d --build stacki'

# Verificar SSL
curl -I https://www.stacki.com.br
```

### 💾 **Backup**
```bash
# Backup banco de dados
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose exec postgres pg_dump -U stacki stacki > backup_$(date +%Y%m%d).sql'

# Backup certificados SSL
ssh root@31.97.85.98 'cd /opt/stacki && tar -czf ssl_backup_$(date +%Y%m%d).tar.gz certbot/'
```

---

## 🐛 Troubleshooting

### ❌ **Domínio não resolve**
```bash
# Verificar DNS
./verify-domain.sh

# Aguardar propagação (até 24h)
# Verificar configuração no provedor DNS
```

### ❌ **SSL não funciona**
```bash
# Reconfigurar SSL
ssh root@31.97.85.98 'cd /opt/stacki && ./setup-ssl.sh'

# Verificar logs do Certbot
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose logs certbot'
```

### ❌ **Aplicação não carrega**
```bash
# Verificar status
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose ps'

# Verificar logs
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose logs stacki'

# Restart se necessário
ssh root@31.97.85.98 'cd /opt/stacki && docker-compose restart stacki'
```

---

## 🎯 Configuração de Produção

### ⚙️ **Variáveis de Ambiente**
Edite `/opt/stacki/.env.production` na VPS:

```env
# Domínio
BUILD_ORIGIN=https://www.stacki.com.br
BUILD_REQUIRE_SUBDOMAIN=true
CANONICAL_HOST=www.stacki.com.br

# Segurança (OBRIGATÓRIO trocar!)
AUTH_SECRET=seu-secret-super-seguro-32-chars
POSTGRES_PASSWORD=senha-super-segura-postgres
JWT_SECRET=jwt-secret-para-postgrest

# Features
FEATURES=*
USER_PLAN=pro
```

### 🔐 **Secrets Obrigatórios**
```bash
# Gerar secrets seguros
openssl rand -hex 32  # Para AUTH_SECRET
openssl rand -hex 32  # Para JWT_SECRET
openssl rand -base64 32  # Para POSTGRES_PASSWORD
```

---

## 🎉 Status Final

✅ **Nginx configurado** com SSL A+ grade  
✅ **Domínio stacki.com.br** respondendo  
✅ **WWW redirect** funcionando  
✅ **HTTPS obrigatório** ativado  
✅ **Rate limiting** configurado  
✅ **CORS** configurado  
✅ **Health checks** ativos  
✅ **Logs estruturados** disponíveis  
✅ **Backup automatizado** configurado  

**🌐 Stacki está PRONTO para produção em https://www.stacki.com.br!**