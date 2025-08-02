#!/bin/bash

# 🔐 Setup SSL para stacki.com.br
# Script para configurar Let's Encrypt SSL

set -e

echo "🔐 Configurando SSL para www.stacki.com.br"
echo "========================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error "Este script deve ser executado como root (sudo)"
fi

# Configuration
DOMAIN="stacki.com.br"
WWW_DOMAIN="www.stacki.com.br"
EMAIL="admin@stacki.com.br"
DEPLOY_PATH="/opt/stacki"

log "🌐 Configurando SSL para domínios:"
echo "   - $DOMAIN"
echo "   - $WWW_DOMAIN"

# Create directories
log "📁 Criando diretórios necessários..."
mkdir -p $DEPLOY_PATH/certbot/conf
mkdir -p $DEPLOY_PATH/certbot/www

# Create initial nginx config without SSL
log "🔧 Criando configuração inicial do Nginx..."
cat > $DEPLOY_PATH/nginx-init.conf << EOF
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name $DOMAIN $WWW_DOMAIN;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://\$host\$request_uri;
        }
    }
}
EOF

# Start nginx temporarily for certificate generation
log "🚀 Iniciando Nginx temporário..."
docker run -d --name nginx-temp \
    -p 80:80 \
    -v $DEPLOY_PATH/nginx-init.conf:/etc/nginx/nginx.conf:ro \
    -v $DEPLOY_PATH/certbot/www:/var/www/certbot:ro \
    nginx:alpine

sleep 5

# Generate SSL certificate
log "🔐 Gerando certificado SSL..."
docker run --rm \
    -v $DEPLOY_PATH/certbot/conf:/etc/letsencrypt \
    -v $DEPLOY_PATH/certbot/www:/var/www/certbot \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d $WWW_DOMAIN

# Stop temporary nginx
log "⏸️ Parando Nginx temporário..."
docker stop nginx-temp || true
docker rm nginx-temp || true

# Verify certificate was created
if [ ! -f "$DEPLOY_PATH/certbot/conf/live/$DOMAIN/fullchain.pem" ]; then
    error "Falha ao gerar certificado SSL"
fi

success "Certificado SSL gerado com sucesso!"

# Set up certificate renewal
log "🔄 Configurando renovação automática..."
cat > $DEPLOY_PATH/renew-certs.sh << 'EOF'
#!/bin/bash
cd /opt/stacki
docker-compose -f docker-compose.production.yml exec certbot certbot renew --quiet
docker-compose -f docker-compose.production.yml exec nginx nginx -s reload
EOF

chmod +x $DEPLOY_PATH/renew-certs.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 12 * * * /opt/stacki/renew-certs.sh") | crontab -

success "Renovação automática configurada!"

# Update nginx configuration to use SSL
log "🔧 Atualizando configuração do Nginx..."
cp nginx.conf $DEPLOY_PATH/

# Start the full stack
log "🚀 Iniciando stack completo..."
cd $DEPLOY_PATH
docker-compose -f docker-compose.production.yml up -d

# Wait for services
log "⏱️ Aguardando serviços iniciarem..."
sleep 30

# Test SSL
log "🧪 Testando SSL..."
if curl -f https://$WWW_DOMAIN/health > /dev/null 2>&1; then
    success "SSL funcionando corretamente!"
else
    warning "SSL pode estar iniciando ainda..."
fi

# Final status
log "🔍 Status dos serviços:"
docker-compose -f docker-compose.production.yml ps

echo
success "Configuração SSL concluída!"
echo "🌐 Stacki disponível em: https://$WWW_DOMAIN"
echo "🔐 Certificado válido para: $DOMAIN, $WWW_DOMAIN"
echo "🔄 Renovação automática configurada (diariamente às 12h)"
echo
echo "Para verificar logs:"
echo "cd $DEPLOY_PATH && docker-compose logs -f nginx"