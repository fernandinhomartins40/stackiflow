#!/bin/bash

# 🔍 Script de Teste de Conectividade Stacki
# Diagnóstico rápido da VPS 31.97.85.98

echo "🔍 Diagnóstico Stacki - 31.97.85.98"
echo "=================================="
echo

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

info() {
    echo -e "${BLUE}🔍 $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test functions
test_ping() {
    info "Testando conectividade básica (ping)..."
    if ping -c 3 31.97.85.98 >/dev/null 2>&1; then
        success "VPS 31.97.85.98 está online"
    else
        error "VPS não responde ao ping"
    fi
    echo
}

test_http() {
    info "Testando porta HTTP (80)..."
    local response=$(curl -m 10 -s -I http://31.97.85.98 2>/dev/null | head -1)
    if [ -n "$response" ]; then
        success "HTTP: $response"
    else
        error "Porta 80 não responde"
    fi
    echo
}

test_https() {
    info "Testando porta HTTPS (443)..."
    local response=$(curl -m 10 -s -I https://31.97.85.98 2>/dev/null | head -1)
    if [ -n "$response" ]; then
        success "HTTPS: $response"
    else
        error "Porta 443 não responde"
    fi
    echo
}

test_domain() {
    info "Testando domínio stacki.com.br..."
    local response=$(curl -m 10 -s -I http://stacki.com.br 2>/dev/null | head -1)
    if [ -n "$response" ]; then
        success "stacki.com.br: $response"
    else
        error "stacki.com.br não responde"
    fi
    echo
}

test_www_domain() {
    info "Testando domínio www.stacki.com.br..."
    local response=$(curl -m 10 -s -I https://www.stacki.com.br 2>/dev/null | head -1)
    if [ -n "$response" ]; then
        success "www.stacki.com.br: $response"
    else
        error "www.stacki.com.br não responde"
    fi
    echo
}

test_health() {
    info "Testando health check..."
    local response=$(curl -m 10 -s https://www.stacki.com.br/health 2>/dev/null)
    if [ -n "$response" ]; then
        success "Health check OK: $response"
    else
        warning "Health check não responde (normal se app não estiver rodando)"
    fi
    echo
}

test_dns() {
    info "Verificando resolução DNS..."
    
    local stacki_ip=$(nslookup stacki.com.br 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
    local www_ip=$(nslookup www.stacki.com.br 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
    
    if [ "$stacki_ip" = "31.97.85.98" ]; then
        success "stacki.com.br → 31.97.85.98"
    else
        error "stacki.com.br → $stacki_ip (esperado: 31.97.85.98)"
    fi
    
    if [ "$www_ip" = "31.97.85.98" ]; then
        success "www.stacki.com.br → 31.97.85.98"
    else
        error "www.stacki.com.br → $www_ip (esperado: 31.97.85.98)"
    fi
    echo
}

test_ssh() {
    info "Testando conectividade SSH..."
    if command -v ssh >/dev/null 2>&1; then
        if ssh -o ConnectTimeout=5 -o BatchMode=yes root@31.97.85.98 "echo 'SSH OK'" 2>/dev/null; then
            success "SSH conecta normalmente"
        else
            warning "SSH requer autenticação (normal)"
        fi
    else
        warning "SSH não disponível neste sistema"
    fi
    echo
}

# Run all tests
test_ping
test_http
test_https
test_domain
test_www_domain
test_health
test_dns
test_ssh

echo "📋 Resumo do Diagnóstico:"
echo "========================"
echo "🌐 VPS IP: 31.97.85.98"
echo "🔗 HTTP: Porta 80"
echo "🔐 HTTPS: Porta 443"
echo "🌍 Domínios: stacki.com.br, www.stacki.com.br"
echo
echo "💡 Próximos passos baseados nos resultados:"
echo "- Se ping falhou: VPS pode estar offline"
echo "- Se HTTP/HTTPS falharam: Deploy não foi executado"
echo "- Se DNS falhou: Registros DNS não configurados"
echo "- Se tudo falhou: Verificar firewall/rede"
echo
echo "🚀 Para deploy manual: export VPS_PASSWORD='senha' && ./deploy-manual.sh"