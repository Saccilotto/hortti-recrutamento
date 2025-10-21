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

# Função para gerar hash bcrypt usando Node.js
generate_bcrypt_hash() {
  local password=$1
  local rounds=${2:-10}

  # Verifica se node está disponível
  if ! command -v node &> /dev/null; then
    echo -e "${RED}Erro: Node.js não está instalado${NC}"
    echo "Por favor, instale Node.js ou execute dentro do container Docker"
    exit 1
  fi

  # Gera hash usando bcrypt via Node.js
  node -e "const bcrypt = require('bcrypt'); bcrypt.hash('${password}', ${rounds}).then(hash => console.log(hash));"
}

# Gerar senhas e secrets
POSTGRES_PASSWORD=$(generate_random)
JWT_SECRET=$(generate_random)
JWT_REFRESH_SECRET=$(generate_random)

echo -e "${YELLOW}Gerando hashes bcrypt para senhas padrão...${NC}"
ADMIN_PASSWORD_HASH=$(generate_bcrypt_hash "Admin@123" 10)
USER_PASSWORD_HASH=$(generate_bcrypt_hash "User@123" 10)

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

# Default User Credentials (for init.sql)
# Admin: admin@cantinhoverde.com / Admin@123
# User: user@cantinhoverde.com / User@123
ADMIN_PASSWORD_HASH=${ADMIN_PASSWORD_HASH}
USER_PASSWORD_HASH=${USER_PASSWORD_HASH}

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

# Gerar init.sql a partir do template
echo -e "${YELLOW}Gerando init.sql com hashes bcrypt...${NC}"
if [ -f backend/db/init.sql.template ]; then
  # Substitui as variáveis no template
  envsubst '${ADMIN_PASSWORD_HASH} ${USER_PASSWORD_HASH}' < backend/db/init.sql.template > backend/db/init.sql
  echo -e "${GREEN}✓ Arquivo backend/db/init.sql gerado com sucesso!${NC}"
else
  echo -e "${RED}⚠️  Template backend/db/init.sql.template não encontrado${NC}"
  echo "  O init.sql não foi atualizado com os novos hashes"
fi
echo ""

echo -e "${YELLOW}Credenciais geradas:${NC}"
echo "  PostgreSQL Password: ${POSTGRES_PASSWORD:0:20}..."
echo "  JWT Secret:          ${JWT_SECRET:0:20}..."
echo "  JWT Refresh Secret:  ${JWT_REFRESH_SECRET:0:20}..."
echo "  Admin Hash:          ${ADMIN_PASSWORD_HASH:0:20}..."
echo "  User Hash:           ${USER_PASSWORD_HASH:0:20}..."
echo ""
echo -e "${GREEN}IMPORTANTE:${NC}"
echo "  1. O arquivo .env está no .gitignore"
echo "  2. NUNCA compartilhe essas credenciais"
echo "  3. Em produção, use variáveis de ambiente do servidor"
echo "  4. Credenciais padrão:"
echo "     - Admin: admin@cantinhoverde.com / Admin@123"
echo "     - User: user@cantinhoverde.com / User@123"
echo ""
echo -e "${GREEN}Próximos passos:${NC}"
echo "  1. Execute: docker compose -f docker-compose-local.yml up --build"
echo "  2. O banco será criado com as credenciais seguras"
echo "  3. Use as credenciais acima para fazer login"
echo ""
