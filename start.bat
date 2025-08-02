@echo off
echo 🚀 Iniciando Stacki - Tailwind-Native Visual Website Builder
echo.
echo 📦 Instalando dependências...
call pnpm install
if %errorlevel% neq 0 (
    echo ❌ Erro ao instalar dependências
    pause
    exit /b 1
)

echo.
echo 🔧 Configurando banco de dados...
cd apps\builder
call pnpm prisma generate
if %errorlevel% neq 0 (
    echo ⚠️  Aviso: Erro na geração do Prisma (continuando...)
)

echo.
echo 🚀 Iniciando servidor de desenvolvimento...
call pnpm dev

pause