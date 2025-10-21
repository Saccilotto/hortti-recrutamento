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
	@echo '  ${GREEN}make setup${RESET}              - Gera .env com credenciais seguras'
	@echo '  ${GREEN}make complete-setup${RESET}     - Setup completo (Terraform + Ansible)'
	@echo ''
	@echo '${YELLOW}Desenvolvimento:${RESET}'
	@echo '  ${GREEN}make dev-local${RESET}          - Inicia dev local (hot-reload)'
	@echo '  ${GREEN}make down${RESET}               - Para todos os containers'
	@echo '  ${GREEN}make logs${RESET}               - Exibe logs de todos os containers'
	@echo ''
	@echo '${YELLOW}Banco de Dados:${RESET}'
	@echo '  ${GREEN}make test-db${RESET}            - Testa conexão com banco'
	@echo '  ${GREEN}make db-shell${RESET}           - Acessa shell do PostgreSQL'
	@echo '  ${GREEN}make db-reset${RESET}           - Reseta banco (CUIDADO!)'
	@echo ''
	@echo '${YELLOW}Infraestrutura (Terraform):${RESET}'
	@echo '  ${GREEN}make infra-setup-backend${RESET} - Cria bucket S3 para Terraform state'
	@echo '  ${GREEN}make infra-init${RESET}         - Inicializa Terraform'
	@echo '  ${GREEN}make infra-plan${RESET}         - Planeja mudanças na infraestrutura'
	@echo '  ${GREEN}make infra-apply${RESET}        - Aplica infraestrutura na AWS'
	@echo '  ${GREEN}make infra-destroy${RESET}      - Destrói infraestrutura (CUIDADO!)'
	@echo '  ${GREEN}make infra-output${RESET}       - Mostra outputs do Terraform'
	@echo ''
	@echo '${YELLOW}Deploy (Ansible):${RESET}'
	@echo '  ${GREEN}make deploy-setup${RESET}       - Configura arquivos Ansible'
	@echo '  ${GREEN}make deploy${RESET}             - Deploy para produção'
	@echo '  ${GREEN}make deploy-check${RESET}       - Verifica conectividade'
	@echo ''
	@echo '${YELLOW}Produção (Quick Commands):${RESET}'
	@echo '  ${GREEN}make prod-deploy${RESET}        - Build + Push + Deploy completo'
	@echo '  ${GREEN}make prod-status${RESET}        - Status dos containers em produção'
	@echo '  ${GREEN}make prod-logs${RESET}          - Logs da produção'
	@echo '  ${GREEN}make prod-restart${RESET}       - Reinicia aplicação em produção'
	@echo ''
	@echo '${YELLOW}Docker Images:${RESET}'
	@echo '  ${GREEN}make docker-build${RESET}       - Build das imagens Docker'
	@echo '  ${GREEN}make docker-push${RESET}        - Push para GitHub Container Registry'
	@echo '  ${GREEN}make docker-build-push${RESET}  - Build + Push'
	@echo ''
	@echo '${YELLOW}Limpeza:${RESET}'
	@echo '  ${GREEN}make clean${RESET}              - Remove node_modules e builds'
	@echo '  ${GREEN}make prune${RESET}              - Remove recursos Docker não usados'
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

# ============================================
# INFRASTRUCTURE (Terraform)
# ============================================
.PHONY: infra-init infra-plan infra-apply infra-destroy infra-output infra-setup-backend

infra-setup-backend:
	@echo "${GREEN}Configurando backend S3 do Terraform...${RESET}"
	@bash infra/terraform/setup-backend.sh

infra-init:
	@echo "${GREEN}Inicializando Terraform...${RESET}"
	cd infra/terraform && terraform init

infra-validate:
	@echo "${GREEN}Validando configuração Terraform...${RESET}"
	cd infra/terraform && terraform validate

infra-plan:
	@echo "${GREEN}Planejando infraestrutura...${RESET}"
	cd infra/terraform && terraform plan

infra-apply:
	@echo "${YELLOW}⚠️  ATENÇÃO: Isso criará recursos na AWS (custos aplicáveis)${RESET}"
	@echo "Pressione Ctrl+C para cancelar ou Enter para continuar..."
	@read confirm
	@echo "${GREEN}Aplicando infraestrutura...${RESET}"
	cd infra/terraform && terraform apply

infra-destroy:
	@echo "${YELLOW}⚠️  PERIGO: Isso destruirá TODA a infraestrutura!${RESET}"
	@echo "Pressione Ctrl+C para cancelar ou Enter para continuar..."
	@read confirm
	@echo "${YELLOW}Destruindo infraestrutura...${RESET}"
	cd infra/terraform && terraform destroy

infra-output:
	@echo "${GREEN}Outputs do Terraform:${RESET}"
	@cd infra/terraform && terraform output

infra-refresh:
	@echo "${GREEN}Atualizando state do Terraform...${RESET}"
	cd infra/terraform && terraform refresh

# ============================================
# DEPLOYMENT (Ansible)
# ============================================
.PHONY: deploy-setup deploy deploy-check deploy-logs

deploy-setup:
	@echo "${GREEN}Configurando Ansible...${RESET}"
	@if [ ! -f infra/ansible/inventory/hosts.ini ]; then \
		cp infra/ansible/inventory/hosts.ini.example infra/ansible/inventory/hosts.ini; \
		echo "${YELLOW}Configure o arquivo infra/ansible/inventory/hosts.ini${RESET}"; \
	fi
	@if [ ! -f infra/ansible/vars/secrets.yml ]; then \
		cp infra/ansible/vars/secrets.yml.example infra/ansible/vars/secrets.yml; \
		echo "${YELLOW}Configure o arquivo infra/ansible/vars/secrets.yml${RESET}"; \
	fi

deploy:
	@echo "${GREEN}Fazendo deploy para produção...${RESET}"
	cd infra/ansible && ansible-playbook playbook.yml

deploy-check:
	@echo "${GREEN}Verificando conectividade...${RESET}"
	cd infra/ansible && ansible production -m ping

deploy-logs:
	@echo "${GREEN}Visualizando logs do servidor...${RESET}"
	cd infra/ansible && ansible production -a "docker compose -f /opt/hortti-inventory/docker-compose.yml logs --tail=50"

# ============================================
# DOCKER IMAGES (Build & Push)
# ============================================
.PHONY: docker-login docker-build docker-push docker-build-push

docker-login:
	@echo "${GREEN}Login no GitHub Container Registry...${RESET}"
	@echo "$${GITHUB_TOKEN}" | docker login ghcr.io -u $${GITHUB_USER} --password-stdin

docker-build:
	@echo "${GREEN}Building Docker images...${RESET}"
	docker build -t ghcr.io/$${GITHUB_USER}/hortti-inventory-backend:latest -f backend/Dockerfile.prod backend/
	docker build -t ghcr.io/$${GITHUB_USER}/hortti-inventory-frontend:latest -f frontend/Dockerfile.prod frontend/

docker-push:
	@echo "${GREEN}Pushing Docker images...${RESET}"
	docker push ghcr.io/$${GITHUB_USER}/hortti-inventory-backend:latest
	docker push ghcr.io/$${GITHUB_USER}/hortti-inventory-frontend:latest

docker-build-push: docker-build docker-push
	@echo "${GREEN}Images built and pushed!${RESET}"

# ============================================
# PRODUCTION QUICK COMMANDS
# ============================================
.PHONY: prod-deploy prod-status prod-logs prod-restart

prod-deploy: docker-build-push deploy
	@echo "${GREEN}Deploy completo finalizado!${RESET}"

prod-status:
	@echo "${GREEN}Status da produção:${RESET}"
	cd infra/ansible && ansible production -a "docker compose -f /opt/hortti-inventory/docker-compose.yml ps"

prod-logs:
	@echo "${GREEN}Logs da produção:${RESET}"
	cd infra/ansible && ansible production -a "docker compose -f /opt/hortti-inventory/docker-compose.yml logs --tail=100 -f"

prod-restart:
	@echo "${YELLOW}Reiniciando aplicação em produção...${RESET}"
	cd infra/ansible && ansible production -a "docker compose -f /opt/hortti-inventory/docker-compose.yml restart"

# ============================================
# COMPLETE WORKFLOW
# ============================================
.PHONY: complete-setup complete-deploy

complete-setup: infra-setup-backend infra-init deploy-setup
	@echo "${GREEN}Setup inicial completo!${RESET}"
	@echo ""
	@echo "${YELLOW}Próximos passos:${RESET}"
	@echo "1. Configure infra/terraform/terraform.tfvars"
	@echo "2. Configure infra/ansible/vars/secrets.yml"
	@echo "3. Execute: make infra-plan"
	@echo "4. Execute: make infra-apply"
	@echo "5. Execute: make deploy"

complete-deploy: infra-apply deploy
	@echo "${GREEN}Deploy completo finalizado!${RESET}"
	@make infra-output
