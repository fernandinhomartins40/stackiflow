#!/bin/bash

# 🔍 Verificador de Conflitos de Banco de Dados - Stacki
# Verifica conflitos com outros bancos PostgreSQL na VPS compartilhada

echo "🔍 Verificando Conflitos de Banco de Dados na VPS"
echo "==============================================="

VPS_HOST="31.97.85.98"
VPS_USER="root"

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

# Function to check SSH connectivity
check_ssh() {
    if command -v ssh >/dev/null 2>&1; then
        if ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_HOST "echo 'SSH OK'" 2>/dev/null; then
            return 0
        else
            warning "SSH requer autenticação (normal se não configurado)"
            return 1
        fi
    else
        error "SSH não disponível neste sistema"
        return 1
    fi
}

echo "🔐 Testando conectividade SSH..."
if ! check_ssh; then
    echo "💡 Para executar verificação completa, configure SSH sem senha ou execute manualmente na VPS."
    echo
fi

echo "🐳 Verificando containers Docker PostgreSQL existentes..."
echo "======================================================="

# Check Docker containers with PostgreSQL
if check_ssh; then
    echo "📊 Containers PostgreSQL ativos:"
    ssh $VPS_USER@$VPS_HOST "docker ps --filter 'ancestor=postgres' --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}' 2>/dev/null || echo 'Nenhum container PostgreSQL encontrado'"
    echo
    
    echo "📊 Todos os containers com PostgreSQL (incluindo parados):"
    ssh $VPS_USER@$VPS_HOST "docker ps -a --filter 'ancestor=postgres' --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || echo 'Nenhum container PostgreSQL encontrado'"
    echo
    
    echo "🌐 Portas PostgreSQL ocupadas (5432, 5433, 5434):"
    ssh $VPS_USER@$VPS_HOST "netstat -tlnp | grep -E ':(5432|5433|5434)' | while read line; do echo \"   \$line\"; done || echo '   Nenhuma porta PostgreSQL ocupada'"
    echo
    
    echo "🗄️ Volumes Docker com postgres/database:"
    ssh $VPS_USER@$VPS_HOST "docker volume ls | grep -i postgres || echo '   Nenhum volume postgres encontrado'"
    ssh $VPS_USER@$VPS_HOST "docker volume ls | grep -i database || echo '   Nenhum volume database encontrado'"
    echo
    
    echo "🌉 Redes Docker existentes:"
    ssh $VPS_USER@$VPS_HOST "docker network ls | grep -v 'bridge\|host\|none' || echo '   Apenas redes padrão'"
    echo
    
    echo "📁 Processos PostgreSQL nativos (fora do Docker):"
    ssh $VPS_USER@$VPS_HOST "ps aux | grep postgres | grep -v grep || echo '   Nenhum PostgreSQL nativo encontrado'"
    echo
else
    echo "⚠️  Verificação via SSH não disponível. Execute manualmente na VPS:"
    echo
    echo "ssh root@$VPS_HOST"
    echo "docker ps --filter 'ancestor=postgres'"
    echo "netstat -tlnp | grep -E ':(5432|5433|5434)'"
    echo "docker volume ls | grep postgres"
    echo "ps aux | grep postgres"
fi

echo "📋 Configuração Stacki Atual:"
echo "============================="
echo "🐳 Container: stacki-postgres-stacki"
echo "🌐 Porta Externa: 5434 → 5432 (container)"
echo "🗄️ Banco: stacki"
echo "👤 Usuário: stacki"
echo "📂 Volume: stacki_postgres_data_vol"
echo "🌉 Rede: stacki_network_isolated (172.20.0.0/16)"

echo
echo "💡 Recomendações para VPS Compartilhada:"
echo "========================================"
echo "✅ Usar porta 5434 para evitar conflito com PostgreSQL padrão (5432)"
echo "✅ Volumes com prefixo 'stacki_' para isolamento"
echo "✅ Rede Docker isolada com subnet específico"
echo "✅ Container names únicos com sufixo do projeto"
echo "✅ Configurar diferentes PGDATA para isolamento completo"

echo
echo "🚨 Possíveis Conflitos:"
echo "======================"
echo "❌ Porta 5432: PostgreSQL padrão do sistema"
echo "❌ Porta 5433: Outro projeto PostgreSQL"
echo "❌ Volumes sem prefixo: Podem colidir com outros projetos"
echo "❌ Nomes de container genéricos: postgres, db, etc."

echo
echo "🔧 Se houver conflitos, ajustar:"
echo "================================"
echo "1. Mudar porta externa: 5434 → 5435 (ou outra disponível)"
echo "2. Verificar se volumes são únicos"
echo "3. Parar containers conflitantes temporariamente"
echo "4. Usar diferentes redes Docker"

echo
echo "📞 Verificação Manual na VPS:"
echo "============================="
echo "# Conectar na VPS"
echo "ssh root@$VPS_HOST"
echo
echo "# Verificar conflitos"
echo "docker ps | grep postgres"
echo "netstat -tlnp | grep 5434"
echo "docker volume ls | grep stacki"
echo
echo "# Parar conflitos (se necessário)"
echo "docker stop \$(docker ps -q --filter 'publish=5434')"
echo "docker stop \$(docker ps -q --filter 'name=postgres')"
echo
echo "# Deploy Stacki"
echo "cd /opt/stacki && docker-compose up -d"