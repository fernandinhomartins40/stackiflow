# 🚀 Stacki - Guia de Deploy

## 📋 Visão Geral

Este documento explica como fazer deploy do **Stacki** na VPS `31.97.85.98` usando diferentes métodos.

---

## 🤖 Deploy Automático (GitHub Actions)

### ✅ Configuração dos Secrets

No repositório GitHub, configure os seguintes secrets:

1. Acesse: `Settings` → `Secrets and variables` → `Actions`
2. Adicione o secret:
   - **Nome:** `VPS_PASSWORD`
   - **Valor:** A senha SSH da VPS

### 🚀 Deploy Automático

O deploy acontece automaticamente quando:
- Push para branch `main`
- Pull Request para `main`
- Trigger manual via GitHub Actions

**Workflow:** `.github/workflows/deploy-vps.yml`

---

## 🛠 Deploy Manual

### 📋 Pré-requisitos

```bash
# No seu computador local
sudo apt install sshpass  # Ubuntu/Debian
brew install hudochenkov/sshpass/sshpass  # macOS

# Variável de ambiente (opcional)
export VPS_PASSWORD="sua_senha_vps"
```

### 🚀 Executar Deploy

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/stackiflow.git
cd stackiflow

# Execute o script de deploy
./deploy-manual.sh
```

---

## 🐳 Deploy via Docker

### 📦 Configuração no Servidor

```bash
# Conectar na VPS
ssh root@31.97.85.98

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar diretório da aplicação
mkdir -p /opt/stacki
cd /opt/stacki
```

### ⚙️ Configuração de Ambiente

```bash
# Copiar configuração de exemplo
cp .env.production.example .env.production

# Editar configurações
nano .env.production
```

**Configurações obrigatórias:**
```env
POSTGRES_PASSWORD=senha_super_segura
AUTH_SECRET=secret_gerado_com_openssl
JWT_SECRET=outro_secret_seguro
BUILD_ORIGIN=http://31.97.85.98:3000
```

### 🚀 Iniciar Aplicação

```bash
# Build e start
docker-compose -f docker-compose.production.yml up -d --build

# Verificar status
docker-compose -f docker-compose.production.yml ps

# Verificar logs
docker-compose -f docker-compose.production.yml logs -f stacki
```

---

## 🌐 Acessos

Após o deploy bem-sucedido:

- **🚀 Stacki App:** https://www.stacki.com.br
- **📊 PostgREST API:** https://www.stacki.com.br/rest/
- **🗄️ PostgreSQL:** 31.97.85.98:5434
- **🔧 Stacki Direct:** http://31.97.85.98:3008 (apenas para debug)
- **🔧 PostgREST Direct:** http://31.97.85.98:3009 (apenas para debug)

### 🔍 Verificação DNS

Antes do primeiro deploy, verifique se o domínio está configurado:

```bash
./verify-domain.sh
```

### 🔐 Configuração SSL

Para configurar SSL com Let's Encrypt na primeira vez:

```bash
# Conectar na VPS
ssh root@31.97.85.98

# Executar configuração SSL
cd /opt/stacki
./setup-ssl.sh
```

---

## 🔧 Comandos Úteis

### 📊 Monitoramento

```bash
# Status dos containers
docker-compose -f docker-compose.production.yml ps

# Logs em tempo real
docker-compose -f docker-compose.production.yml logs -f

# Logs específicos
docker-compose -f docker-compose.production.yml logs stacki
docker-compose -f docker-compose.production.yml logs postgres

# Uso de recursos
docker stats
```

### 🔄 Operações

```bash
# Restart aplicação
docker-compose -f docker-compose.production.yml restart stacki

# Rebuild aplicação
docker-compose -f docker-compose.production.yml up -d --build stacki

# Parar tudo
docker-compose -f docker-compose.production.yml down

# Parar e limpar volumes (CUIDADO!)
docker-compose -f docker-compose.production.yml down -v
```

### 💾 Backup

```bash
# Backup do banco
docker-compose -f docker-compose.production.yml exec postgres pg_dump -U stacki stacki > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup dos volumes
docker run --rm -v stacki_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

---

## 🐛 Troubleshooting

### ❌ Problemas Comuns

#### 1. Erro de conexão SSH
```bash
# Testar conexão
ssh root@31.97.85.98

# Verificar se sshpass está instalado
which sshpass
```

#### 2. Erro de build
```bash
# Verificar logs do build
docker-compose -f docker-compose.production.yml logs stacki

# Rebuild forçado
docker-compose -f docker-compose.production.yml build --no-cache stacki
```

#### 3. Banco de dados não conecta
```bash
# Verificar se PostgreSQL está rodando
docker-compose -f docker-compose.production.yml ps postgres

# Testar conexão
docker-compose -f docker-compose.production.yml exec postgres psql -U stacki -d stacki
```

#### 4. Porta ocupada
```bash
# Verificar portas em uso
netstat -tlnp | grep :3000

# Parar processo na porta
sudo kill -9 $(sudo lsof -t -i:3000)
```

### 🔍 Logs Detalhados

```bash
# Ver todas as informações
docker-compose -f docker-compose.production.yml config
docker-compose -f docker-compose.production.yml top
docker system df
docker system events
```

---

## 🔐 Segurança

### 🛡️ Práticas Recomendadas

1. **Firewall:**
   ```bash
   ufw allow 22    # SSH
   ufw allow 80    # HTTP
   ufw allow 443   # HTTPS
   ufw allow 3000  # Stacki
   ufw enable
   ```

2. **SSL (opcional):**
   ```bash
   # Instalar Certbot
   apt install certbot
   
   # Gerar certificado
   certbot certonly --standalone -d seu-dominio.com
   ```

3. **Secrets Seguros:**
   - Use senhas fortes (32+ caracteres)
   - Gere secrets com `openssl rand -hex 32`
   - Não commite secrets no Git

### 🔄 Atualizações

```bash
# Atualizar imagens Docker
docker-compose -f docker-compose.production.yml pull

# Aplicar atualizações
docker-compose -f docker-compose.production.yml up -d
```

---

## 📞 Suporte

Em caso de problemas:

1. Verificar logs: `docker-compose logs`
2. Verificar status: `docker-compose ps`
3. Restart: `docker-compose restart`
4. Rebuild: `docker-compose up -d --build`

---

*🚀 Stacki rodando em produção na VPS!*