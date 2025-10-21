#!/bin/bash

# ============================================
# Test PostgreSQL Connection
# ============================================
# Script para testar a conexão com o banco de dados
# e verificar se as tabelas foram criadas corretamente
# ============================================

set -e

echo "=================================="
echo "Testando conexão com PostgreSQL"
echo "=================================="
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações (pode ser alterado via variáveis de ambiente)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_PASS="${DB_PASS:-postgres}"
DB_NAME="${DB_NAME:-hortti_inventory}"

echo "Configurações:"
echo "  Host: $DB_HOST"
echo "  Porta: $DB_PORT"
echo "  Usuário: $DB_USER"
echo "  Banco: $DB_NAME"
echo ""

# Testar conexão
echo "1. Testando conexão com o banco..."
if PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c '\q' 2>/dev/null; then
  echo -e "${GREEN}✓ Conexão estabelecida com sucesso!${NC}"
else
  echo -e "${RED}✗ Falha ao conectar com o banco${NC}"
  exit 1
fi
echo ""

# Verificar tabelas
echo "2. Verificando tabelas criadas..."
TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';")

if [ -z "$TABLES" ]; then
  echo -e "${RED}✗ Nenhuma tabela encontrada${NC}"
  exit 1
else
  echo -e "${GREEN}✓ Tabelas encontradas:${NC}"
  echo "$TABLES" | sed 's/^/    /'
fi
echo ""

# Verificar usuários
echo "3. Verificando usuários..."
USER_COUNT=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM users;")
echo -e "   Total de usuários: ${GREEN}$USER_COUNT${NC}"

if [ "$USER_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✓ Usuários de seed carregados:${NC}"
  PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT id, email, name, role FROM users;"
fi
echo ""

# Verificar produtos
echo "4. Verificando produtos..."
PRODUCT_COUNT=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM products;")
echo -e "   Total de produtos: ${GREEN}$PRODUCT_COUNT${NC}"

if [ "$PRODUCT_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✓ Produtos por categoria:${NC}"
  PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT category, COUNT(*) as total FROM products GROUP BY category ORDER BY category;"
fi
echo ""

# Verificar views
echo "5. Verificando views..."
VIEWS=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT table_name FROM information_schema.views WHERE table_schema = 'public';")

if [ -z "$VIEWS" ]; then
  echo -e "${YELLOW}⚠ Nenhuma view encontrada${NC}"
else
  echo -e "${GREEN}✓ Views criadas:${NC}"
  echo "$VIEWS" | sed 's/^/    /'
fi
echo ""

# Testar busca
echo "6. Testando busca de produtos (ILIKE)..."
SEARCH_RESULT=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM products WHERE name ILIKE '%tomate%';")
echo -e "   Produtos com 'tomate' no nome: ${GREEN}$SEARCH_RESULT${NC}"
echo ""

# Testar ordenação
echo "7. Testando ordenação por preço..."
echo -e "${GREEN}✓ Top 5 produtos mais caros:${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT name, category, price FROM products ORDER BY price DESC LIMIT 5;"
echo ""

# Resumo
echo "=================================="
echo -e "${GREEN}✓ Todos os testes passaram!${NC}"
echo "=================================="
echo ""
echo "Banco de dados está pronto para uso!"
echo ""
echo "Credenciais de acesso:"
echo "  Admin: admin@cantinhoverde.com / Admin@123"
echo "  User:  user@cantinhoverde.com / User@123"
echo ""
