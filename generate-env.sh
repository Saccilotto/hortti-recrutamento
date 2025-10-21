#!/bin/bash

# ============================================
# Generate .env file with secure random values
# ============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=================================="
echo "Gerando arquivo .env seguro"
echo -e "==================================${NC}"
echo ""

# Verificar se .env já existe
if [ -f .env ]; then
  echo -e "${YELLOW}⚠️  Arquivo .env já existe!${NC}"
  echo "Deseja sobrescrever? (s/N)"
  read -r response
  if [[ ! "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
    echo -e "${RED}Operação cancelada.${NC}"
    exit 0
  fi
fi

# Função para gerar string aleatória
generate_random() {
  openssl rand -base64 48 | tr -d "=+/" | cut -c1-64
}

# Gerar senhas e secrets
POSTGRES_PASSWORD=$(generate_random)
JWT_SECRET=$(generate_random)
JWT_REFRESH_SECRET=$(generate_random)

# Criar arquivo .env
cat > .env << EOF
# ============================================
# Hortti Inventory - Docker Compose Environment
# ============================================
# GERADO AUTOMATICAMENTE EM $(date)
# ATENÇÃO: NUNCA COMMITE ESTE ARQUIVO NO GIT!
# ============================================

# ============================================
# POSTGRESQL
# ============================================
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=hortti_inventory
POSTGRES_PORT=5432

# ============================================
# BACKEND
# ============================================
BACKEND_PORT=3001
NODE_ENV=development

# Database Connection
DB_HOST=db
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=${POSTGRES_PASSWORD}
DB_DATABASE=hortti_inventory
DB_SYNCHRONIZE=false
DB_LOGGING=true

# JWT Configuration
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRATION=1d
JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}
JWT_REFRESH_EXPIRATION=7d

# Bcrypt
BCRYPT_ROUNDS=10

# CORS
CORS_ORIGIN=http://localhost:3000

# Uploads
UPLOAD_DEST=./uploads
UPLOAD_MAX_FILE_SIZE=5242880

# ============================================
# FRONTEND
# ============================================
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:3001/api
EOF

echo -e "${GREEN}✓ Arquivo .env criado com sucesso!${NC}"
echo ""
echo -e "${YELLOW}Credenciais geradas:${NC}"
echo "  PostgreSQL Password: ${POSTGRES_PASSWORD:0:20}..."
echo "  JWT Secret:          ${JWT_SECRET:0:20}..."
echo "  JWT Refresh Secret:  ${JWT_REFRESH_SECRET:0:20}..."
echo ""
echo -e "${GREEN}IMPORTANTE:${NC}"
echo "  1. O arquivo .env está no .gitignore"
echo "  2. NUNCA compartilhe essas credenciais"
echo "  3. Em produção, use variáveis de ambiente do servidor"
echo ""
echo -e "${GREEN}Próximos passos:${NC}"
echo "  1. Execute: docker compose -f docker-compose-local.yml up"
echo "  2. O banco será criado com as credenciais seguras"
echo ""
