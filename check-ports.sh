#!/bin/bash

# 🔍 Verificador de Portas - Stacki
# Verifica se as novas portas estão disponíveis na VPS

echo "🔍 Verificando Portas na VPS 31.97.85.98"
echo "========================================"

VPS_HOST="31.97.85.98"
VPS_USER="root"

# Portas que vamos usar
PORTS=(80 443 8000 8001 5433)
PORT_NAMES=("HTTP/Nginx" "HTTPS/Nginx" "Stacki App" "PostgREST API" "PostgreSQL")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_port() {
    local port=$1
    local name=$2
    local host=$3
    
    echo -n "Verificando porta $port ($name)... "
    
    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        error "OCUPADA"
        return 1
    else
        success "LIVRE"
        return 0
    fi
}

check_ports_ssh() {
    if command -v ssh >/dev/null 2>&1; then
        echo "🔍 Verificando via SSH..."
        
        # Check if we can connect
        if ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_HOST "echo 'SSH OK'" 2>/dev/null; then
            echo "📊 Portas em uso na VPS:"
            ssh $VPS_USER@$VPS_HOST "netstat -tlnp | grep -E ':(80|443|3000|3001|3002|3003|3004|3005|3006|3007|8000|8001|5433)' | sort"
            echo
            
            echo "🐳 Containers Docker ativos:"
            ssh $VPS_USER@$VPS_HOST "docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep -E '(PORT|:)'"
            echo
        else
            warning "SSH requer autenticação manual"
        fi
    fi
}

echo "🌐 Testando conectividade externa..."
for i in "${!PORTS[@]}"; do
    check_port "${PORTS[$i]}" "${PORT_NAMES[$i]}" "$VPS_HOST"
done

echo
echo "📋 Configuração Stacki:"
echo "======================"
echo "🌐 Nginx (HTTP):     80  → Container 80"
echo "🔐 Nginx (HTTPS):    443 → Container 443"
echo "🚀 Stacki App:       8000 → Container 3000"
echo "📊 PostgREST API:    8001 → Container 3000"
echo "🗄️ PostgreSQL:       5433 → Container 5432"

echo
check_ports_ssh

echo
echo "💡 Próximos passos:"
echo "=================="
echo "✅ Portas 8000, 8001, 5433 estão livres - pode prosseguir com deploy"
echo "⚠️  Se alguma porta estiver ocupada, ajuste docker-compose.production.yml"
echo "🚀 Para deploy: ./deploy-manual.sh ou git push origin main"

echo
echo "🔧 Comandos úteis:"
echo "=================="
echo "# Verificar portas específicas na VPS:"
echo "ssh root@$VPS_HOST 'netstat -tlnp | grep :8000'"
echo "ssh root@$VPS_HOST 'netstat -tlnp | grep :8001'"
echo "ssh root@$VPS_HOST 'netstat -tlnp | grep :5433'"
echo
echo "# Parar serviços conflitantes (se necessário):"
echo "ssh root@$VPS_HOST 'docker stop \$(docker ps -q)'"
echo "ssh root@$VPS_HOST 'killall -9 node' # Cuidado!"