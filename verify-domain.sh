#!/bin/bash

# 🌐 Verificação de DNS para stacki.com.br
# Script para verificar se o domínio está apontando corretamente

echo "🌐 Verificando DNS para stacki.com.br"
echo "===================================="

VPS_IP="31.97.85.98"
DOMAIN="stacki.com.br"
WWW_DOMAIN="www.stacki.com.br"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_dns() {
    local domain=$1
    local expected_ip=$2
    
    echo -n "Verificando $domain... "
    
    # Try different DNS resolution methods
    local resolved_ip=""
    
    # Method 1: dig
    if command -v dig &> /dev/null; then
        resolved_ip=$(dig +short $domain | tail -n1)
    elif command -v nslookup &> /dev/null; then
        # Method 2: nslookup
        resolved_ip=$(nslookup $domain | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
    elif command -v host &> /dev/null; then
        # Method 3: host
        resolved_ip=$(host $domain | grep "has address" | awk '{print $4}' | head -1)
    fi
    
    if [ "$resolved_ip" = "$expected_ip" ]; then
        echo -e "${GREEN}✅ OK ($resolved_ip)${NC}"
        return 0
    else
        echo -e "${RED}❌ ERRO (esperado: $expected_ip, obtido: $resolved_ip)${NC}"
        return 1
    fi
}

echo "🔍 Verificando resolução DNS..."
echo

# Check main domain
check_dns $DOMAIN $VPS_IP
domain_ok=$?

# Check www subdomain  
check_dns $WWW_DOMAIN $VPS_IP
www_ok=$?

echo
echo "📊 Resumo:"
if [ $domain_ok -eq 0 ]; then
    echo -e "${GREEN}✅ $DOMAIN → $VPS_IP${NC}"
else
    echo -e "${RED}❌ $DOMAIN não está apontando para $VPS_IP${NC}"
fi

if [ $www_ok -eq 0 ]; then
    echo -e "${GREEN}✅ $WWW_DOMAIN → $VPS_IP${NC}"
else
    echo -e "${RED}❌ $WWW_DOMAIN não está apontando para $VPS_IP${NC}"
fi

echo
if [ $domain_ok -eq 0 ] && [ $www_ok -eq 0 ]; then
    echo -e "${GREEN}🎉 DNS configurado corretamente!${NC}"
    echo "✅ Você pode prosseguir com o deploy"
    
    # Test connectivity
    echo
    echo "🔗 Testando conectividade HTTP..."
    if curl -s --connect-timeout 5 http://$VPS_IP > /dev/null; then
        echo -e "${GREEN}✅ VPS respondendo na porta 80${NC}"
    else
        echo -e "${YELLOW}⚠️  VPS não está respondendo na porta 80${NC}"
    fi
    
    if curl -s --connect-timeout 5 https://$VPS_IP > /dev/null 2>&1; then
        echo -e "${GREEN}✅ VPS respondendo na porta 443${NC}"
    else
        echo -e "${YELLOW}⚠️  VPS não está respondendo na porta 443 (normal se SSL não configurado)${NC}"
    fi
    
else
    echo -e "${RED}❌ DNS não configurado corretamente!${NC}"
    echo
    echo "📝 Para corrigir, configure os seguintes registros DNS:"
    echo "   Tipo A: $DOMAIN → $VPS_IP"
    echo "   Tipo A: $WWW_DOMAIN → $VPS_IP"
    echo
    echo "💡 Exemplos de configuração:"
    echo "   @ IN A $VPS_IP"
    echo "   www IN A $VPS_IP"
    echo
    echo "⏱️  Aguarde até 24h para propagação DNS completa"
fi

echo
echo "🔧 Comandos úteis:"
echo "   Verificar DNS: dig $DOMAIN"
echo "   Verificar WWW: dig $WWW_DOMAIN"
echo "   Testar conectividade: curl -I http://$VPS_IP"
echo "   Deploy manual: ./deploy-manual.sh"