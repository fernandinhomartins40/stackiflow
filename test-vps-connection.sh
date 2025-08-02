#!/bin/bash

# 🔍 Teste de Conectividade VPS - Stacki
# Verifica se a VPS 31.97.85.98 está acessível para deploy

echo "🔍 Teste de Conectividade VPS 31.97.85.98"
echo "========================================"

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

# Test functions
test_ping() {
    info "1. Testando conectividade básica (ping)..."
    if ping -c 3 $VPS_HOST >/dev/null 2>&1; then
        success "VPS está online e responde ping"
        return 0
    else
        error "VPS não responde ao ping"
        return 1
    fi
}

test_ssh_port() {
    info "2. Testando porta SSH (22)..."
    if command -v nc >/dev/null 2>&1; then
        if timeout 10 nc -z $VPS_HOST 22 2>/dev/null; then
            success "Porta SSH 22 está aberta"
            return 0
        else
            error "Porta SSH 22 não responde"
            return 1
        fi
    elif command -v telnet >/dev/null 2>&1; then
        if timeout 10 bash -c "</dev/tcp/$VPS_HOST/22" 2>/dev/null; then
            success "Porta SSH 22 está aberta"
            return 0
        else
            error "Porta SSH 22 não responde"
            return 1
        fi
    else
        warning "nc ou telnet não disponível - pulando teste de porta"
        return 0
    fi
}

test_http() {
    info "3. Testando conectividade HTTP..."
    if curl -I --connect-timeout 10 http://$VPS_HOST >/dev/null 2>&1; then
        success "HTTP respondendo"
        return 0
    else
        warning "HTTP não responde (normal se nginx não estiver rodando)"
        return 0
    fi
}

test_ssh_auth() {
    info "4. Testando autenticação SSH..."
    
    if [ -z "$VPS_PASSWORD" ]; then
        echo -n "Digite a senha da VPS (ou Enter para pular): "
        read -s VPS_PASSWORD
        echo
    fi
    
    if [ -n "$VPS_PASSWORD" ]; then
        if command -v sshpass >/dev/null 2>&1; then
            if timeout 15 sshpass -p "$VPS_PASSWORD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST "echo 'SSH OK'" 2>/dev/null; then
                success "SSH com senha funciona"
                return 0
            else
                error "SSH com senha falhou"
                return 1
            fi
        else
            warning "sshpass não instalado - teste manual necessário"
            info "Instale: sudo apt install sshpass (Ubuntu) ou brew install hudochenkov/sshpass/sshpass (macOS)"
            return 0
        fi
    else
        warning "Senha não fornecida - pulando teste SSH"
        return 0
    fi
}

test_deploy_ports() {
    info "5. Testando portas da aplicação..."
    
    local ports=(3008 3009 5434)
    local port_names=("Stacki App" "PostgREST" "PostgreSQL")
    local all_good=true
    
    for i in "${!ports[@]}"; do
        local port="${ports[$i]}"
        local name="${port_names[$i]}"
        
        if command -v nc >/dev/null 2>&1; then
            if timeout 5 nc -z $VPS_HOST $port 2>/dev/null; then
                success "Porta $port ($name) está aberta"
            else
                info "Porta $port ($name) fechada (normal se app não estiver rodando)"
            fi
        fi
    done
}

# Run all tests
echo "🔗 Iniciando testes de conectividade..."
echo

ping_ok=false
ssh_port_ok=false
http_ok=false
ssh_auth_ok=false

test_ping && ping_ok=true
test_ssh_port && ssh_port_ok=true
test_http && http_ok=true
test_ssh_auth && ssh_auth_ok=true
test_deploy_ports

echo
echo "📊 Resumo dos Testes:"
echo "===================="

if [ "$ping_ok" = true ]; then
    success "Ping: VPS online"
else
    error "Ping: VPS offline ou rede com problemas"
fi

if [ "$ssh_port_ok" = true ]; then
    success "SSH Port: Acessível"
else
    error "SSH Port: Bloqueado ou SSH daemon parado"
fi

if [ "$ssh_auth_ok" = true ]; then
    success "SSH Auth: Funcionando"
else
    error "SSH Auth: Falha na autenticação"
fi

echo
echo "💡 Diagnóstico:"
echo "==============="

if [ "$ping_ok" = false ]; then
    error "VPS pode estar offline ou com problemas de rede"
    echo "   → Verificar status do servidor com o provedor"
    echo "   → Verificar configurações de rede/firewall"
fi

if [ "$ssh_port_ok" = false ]; then
    error "SSH não está acessível"
    echo "   → Verificar se SSH daemon está rodando: systemctl status ssh"
    echo "   → Verificar firewall: ufw status"
    echo "   → Verificar security groups no provedor"
fi

if [ "$ssh_auth_ok" = false ]; then
    error "Problema de autenticação SSH"
    echo "   → Verificar senha correta"
    echo "   → Considerar usar SSH keys em vez de senha"
    echo "   → Verificar logs SSH: tail -f /var/log/auth.log"
fi

echo
echo "🔧 Próximos Passos:"
echo "==================="

if [ "$ping_ok" = true ] && [ "$ssh_port_ok" = true ] && [ "$ssh_auth_ok" = true ]; then
    success "Conectividade OK - Deploy deve funcionar!"
    echo "   → Execute: ./deploy-manual.sh"
    echo "   → Ou configure GitHub Actions secrets"
elif [ "$ping_ok" = true ] && [ "$ssh_port_ok" = true ]; then
    warning "Rede OK, problema de autenticação SSH"
    echo "   → Verificar senha da VPS"
    echo "   → Configurar SSH keys"
    echo "   → Verificar configuração SSH na VPS"
else
    error "Problemas de conectividade básica"
    echo "   → Verificar status da VPS com provedor"
    echo "   → Verificar configurações de firewall"
    echo "   → Aguardar resolução de problemas de rede"
fi

echo
echo "📞 Comandos Úteis:"
echo "=================="
echo "# Teste manual SSH:"
echo "ssh $VPS_USER@$VPS_HOST"
echo
echo "# Deploy manual (se SSH funcionar):"
echo "export VPS_PASSWORD='sua_senha'"
echo "./deploy-manual.sh"
echo
echo "# Debug na VPS:"
echo "ssh $VPS_USER@$VPS_HOST 'systemctl status ssh'"
echo "ssh $VPS_USER@$VPS_HOST 'ufw status'"
echo "ssh $VPS_USER@$VPS_HOST 'docker ps'"