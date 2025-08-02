#!/bin/bash

# 🚀 Stacki Manual Deploy Script
# Para fazer deploy manual na VPS 31.97.85.98

set -e

echo "🚀 Stacki Manual Deploy Script"
echo "=============================="

# Configuration
VPS_HOST="31.97.85.98"
VPS_USER="root"
DEPLOY_PATH="/opt/stacki"
APP_NAME="stacki"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if sshpass is available
if ! command -v sshpass &> /dev/null; then
    error "sshpass não encontrado. Instale com: sudo apt install sshpass"
fi

# Check if VPS_PASSWORD is set
if [ -z "$VPS_PASSWORD" ]; then
    echo -n "Digite a senha da VPS: "
    read -s VPS_PASSWORD
    echo
fi

# Function to execute SSH commands
ssh_exec() {
    sshpass -p "$VPS_PASSWORD" ssh -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "$1"
}

# Function to copy files via SCP
scp_copy() {
    sshpass -p "$VPS_PASSWORD" scp -o StrictHostKeyChecking=no -r "$1" "$VPS_USER@$VPS_HOST:$2"
}

log "🔧 Preparando build local..."

# Build the application
log "📦 Instalando dependências..."
pnpm install || error "Falha ao instalar dependências"

log "🏗️ Building aplicação..."
pnpm build || error "Falha no build"

# Create deployment package
log "📋 Criando pacote de deploy..."
tar -czf stacki-deploy.tar.gz \
    apps/builder/build \
    apps/builder/package.json \
    apps/builder/prisma \
    packages \
    package.json \
    pnpm-lock.yaml \
    stacki.config.js \
    docker-compose.production.yml \
    Dockerfile.production \
    .env.production.example

success "Pacote criado: stacki-deploy.tar.gz"

log "🚀 Iniciando deploy na VPS..."

# Create deployment directory
log "📁 Criando diretório de deploy..."
ssh_exec "mkdir -p $DEPLOY_PATH"

# Check for port conflicts
log "🔍 Verificando conflitos de porta..."
ssh_exec "echo 'Verificando portas 3008, 3009, 5434...'"
ssh_exec "netstat -tlnp | grep -E ':(3008|3009|5434)' && echo 'AVISO: Algumas portas podem estar ocupadas' || echo 'Portas disponíveis'"

# Check for database conflicts
log "🗄️ Verificando conflitos de banco de dados..."
ssh_exec "docker ps --filter 'ancestor=postgres' --format 'table {{.Names}}\t{{.Ports}}' | grep -v 'PORTS' || echo 'Nenhum PostgreSQL conflitante'"
ssh_exec "docker volume ls | grep postgres | grep -v stacki || echo 'Nenhum volume PostgreSQL conflitante'"

# Stop existing services
log "⏸️ Parando serviços existentes..."
ssh_exec "cd $DEPLOY_PATH && docker-compose down || true"

# Stop any conflicting services on the new ports
log "🛑 Parando serviços conflitantes nas novas portas..."
ssh_exec "docker stop \$(docker ps -q --filter 'publish=3008' --filter 'publish=3009' --filter 'publish=5434') 2>/dev/null || true"

# Clean up conflicting networks
log "🌉 Limpando redes conflitantes..."
ssh_exec "docker network rm stacki_network_isolated 2>/dev/null || true"

# Backup current version
log "📦 Fazendo backup da versão atual..."
ssh_exec "cd $DEPLOY_PATH && [ -d 'current' ] && rm -rf backup && mv current backup || true"

# Create new deployment directory
ssh_exec "mkdir -p $DEPLOY_PATH/current"

# Upload deployment package
log "📤 Enviando arquivos..."
scp_copy "stacki-deploy.tar.gz" "$DEPLOY_PATH/current/"

# Extract and configure
log "📦 Extraindo e configurando..."
ssh_exec "cd $DEPLOY_PATH/current && tar -xzf stacki-deploy.tar.gz && rm stacki-deploy.tar.gz"

# Copy production environment if exists
ssh_exec "[ -f '$DEPLOY_PATH/.env.production' ] && cp $DEPLOY_PATH/.env.production $DEPLOY_PATH/current/apps/builder/.env || true"

# Start services
log "🐳 Iniciando serviços Docker..."
ssh_exec "cd $DEPLOY_PATH/current && docker-compose -f docker-compose.production.yml up -d --build"

# Wait for services to start
log "⏱️ Aguardando serviços iniciarem..."
sleep 30

# Check status
log "🔍 Verificando status dos serviços..."
ssh_exec "cd $DEPLOY_PATH/current && docker-compose -f docker-compose.production.yml ps"

# Health check
log "🏥 Verificando saúde da aplicação..."
if ssh_exec "curl -f http://localhost:3000 > /dev/null 2>&1"; then
    success "Aplicação está rodando!"
else
    warning "Aplicação pode estar iniciando ainda..."
fi

# Cleanup
log "🧹 Limpando arquivos temporários..."
rm -f stacki-deploy.tar.gz

success "Deploy concluído com sucesso!"
echo
echo "🌐 Stacki está disponível em: https://www.stacki.com.br"
echo "📊 Monitoramento: https://www.stacki.com.br/rest/"
echo "🔧 Para configurar SSL: ssh root@$VPS_HOST 'cd /opt/stacki && ./setup-ssl.sh'"
echo
echo "Para verificar logs:"
echo "ssh root@$VPS_HOST 'cd $DEPLOY_PATH/current && docker-compose logs -f'"