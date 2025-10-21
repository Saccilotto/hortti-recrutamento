# ============================================
# Hortti Inventory - Makefile
# ============================================
# Comandos úteis para desenvolvimento
# ============================================

.PHONY: help dev-local dev-container down clean test-db logs install setup

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

help:
	@echo ''
	@echo '${GREEN}Hortti Inventory - Comandos Disponíveis${RESET}'
	@echo ''
	@echo '${YELLOW}Setup Inicial:${RESET}'
	@echo '  ${GREEN}make setup${RESET}          - Gera .env com credenciais seguras'
	@echo ''
	@echo '${YELLOW}Desenvolvimento:${RESET}'
	@echo '  ${GREEN}make dev-local${RESET}      - Inicia dev local (hot-reload com volumes)'
	@echo '  ${GREEN}make down${RESET}           - Para todos os containers'
	@echo '  ${GREEN}make logs${RESET}           - Exibe logs de todos os containers'
	@echo ''
	@echo '${YELLOW}Banco de Dados:${RESET}'
	@echo '  ${GREEN}make test-db${RESET}        - Testa conexão com banco de dados'
	@echo '  ${GREEN}make db-shell${RESET}       - Acessa shell do PostgreSQL'
	@echo '  ${GREEN}make db-reset${RESET}       - Reseta banco de dados (CUIDADO!)'
	@echo ''
	@echo '${YELLOW}Instalação:${RESET}'
	@echo '  ${GREEN}make install${RESET}        - Instala dependências (backend + frontend)'
	@echo ''
	@echo '${YELLOW}Limpeza:${RESET}'
	@echo '  ${GREEN}make clean${RESET}          - Remove node_modules, builds e volumes'
	@echo '  ${GREEN}make prune${RESET}          - Remove recursos Docker não utilizados'
	@echo ''

setup:
	@echo "${GREEN}Gerando arquivo .env com credenciais seguras...${RESET}"
	@bash generate-env.sh
	@echo "${GREEN}Setup concluído! Execute 'make dev-local' para iniciar${RESET}"

dev-local:
	@echo "${GREEN}Iniciando dev local (hot-reload)...${RESET}"
	docker compose -f docker-compose-local.yml up --build

dev-local-detach:
	@echo "${GREEN}Iniciando dev local (background)...${RESET}"
	docker compose -f docker-compose-local.yml up -d --build
	@echo "${GREEN}Containers rodando em background!${RESET}"
	@echo "Use 'make logs' para ver os logs"

down:
	@echo "${YELLOW}Parando containers...${RESET}"
	docker compose -f docker-compose-local.yml down
	@echo "${GREEN}Todos os containers foram parados!${RESET}"

# ============================================
# LOGS
# ============================================
logs:
	@echo "${GREEN}Exibindo logs...${RESET}"
	docker compose -f docker-compose-local.yml logs -f

logs-backend:
	docker compose -f docker-compose-local.yml logs -f backend

logs-frontend:
	docker compose -f docker-compose-local.yml logs -f frontend

logs-db:
	docker compose -f docker-compose-local.yml logs -f db

# ============================================
# BANCO DE DADOS
# ============================================
test-db:
	@echo "${GREEN}Testando conexão com banco de dados...${RESET}"
	@bash backend/db/test-connection.sh

db-shell:
	@echo "${GREEN}Acessando shell do PostgreSQL...${RESET}"
	docker compose -f docker-compose-local.yml exec db psql -U postgres -d hortti_inventory

db-reset:
	@echo "${YELLOW}⚠️  ATENÇÃO: Isso irá resetar TODOS os dados do banco!${RESET}"
	@echo "Pressione Ctrl+C para cancelar ou Enter para continuar..."
	@read confirm
	@echo "${YELLOW}Resetando banco de dados...${RESET}"
	docker compose -f docker-compose-local.yml down -v
	docker compose -f docker-compose-local.yml up -d db
	@echo "${GREEN}Banco de dados resetado!${RESET}"

# ============================================
# INSTALAÇÃO
# ============================================
install:
	@echo "${GREEN}Instalando dependências do backend...${RESET}"
	cd backend && npm install
	@echo "${GREEN}Instalando dependências do frontend...${RESET}"
	cd frontend && npm install
	@echo "${GREEN}Todas as dependências foram instaladas!${RESET}"

install-backend:
	@echo "${GREEN}Instalando dependências do backend...${RESET}"
	cd backend && npm install

install-frontend:
	@echo "${GREEN}Instalando dependências do frontend...${RESET}"
	cd frontend && npm install

# ============================================
# LIMPEZA
# ============================================
clean:
	@echo "${YELLOW}Removendo node_modules e builds...${RESET}"
	rm -rf backend/node_modules
	rm -rf backend/dist
	rm -rf backend/dist.*
	rm -rf frontend/node_modules
	rm -rf frontend/.next
	rm -rf frontend/.next.*
	@echo "${GREEN}Limpeza concluída!${RESET}"

prune:
	@echo "${YELLOW}Removendo recursos Docker não utilizados...${RESET}"
	docker system prune -af --volumes
	@echo "${GREEN}Limpeza Docker concluída!${RESET}"

# ============================================
# TESTES
# ============================================
test:
	@echo "${GREEN}Rodando testes do backend...${RESET}"
	cd backend && npm test

test-cov:
	@echo "${GREEN}Rodando testes com cobertura...${RESET}"
	cd backend && npm run test:cov

# ============================================
# BUILD
# ============================================
build-backend:
	@echo "${GREEN}Fazendo build do backend...${RESET}"
	cd backend && npm run build

build-frontend:
	@echo "${GREEN}Fazendo build do frontend...${RESET}"
	cd frontend && npm run build

build-all: build-backend build-frontend
	@echo "${GREEN}Todos os builds foram concluídos!${RESET}"

# ============================================
# STATUS
# ============================================
status:
	@echo "${GREEN}Status dos containers:${RESET}"
	@docker compose -f docker-compose-local.yml ps

ps: status

# ============================================
# RESTART
# ============================================
restart:
	@echo "${YELLOW}Reiniciando containers...${RESET}"
	docker compose -f docker-compose-local.yml restart
	@echo "${GREEN}Containers reiniciados!${RESET}"

restart-backend:
	docker compose -f docker-compose-local.yml restart backend

restart-frontend:
	docker compose -f docker-compose-local.yml restart frontend

restart-db:
	docker compose -f docker-compose-local.yml restart db
