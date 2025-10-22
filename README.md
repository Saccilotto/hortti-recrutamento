# Hortti Inventory

Sistema fullstack para gestão de inventário do "Cantinho Verde" com NestJS, Next.js, PostgreSQL e Docker.

## 🛠️ Tecnologias

**Backend:** NestJS 10.3 | TypeScript 5.3 | TypeORM | PostgreSQL 15 | JWT | Multer
**Frontend:** Next.js 14.0 | React 18.2 | TypeScript 5.3 | Tailwind CSS 3.4 | Axios
**DevOps:** Docker | Docker Compose | GitHub Actions | Terraform | Ansible | AWS | Cloudflare

## 📁 Estrutura

```text
├── backend/          # API NestJS
│   ├── src/          # Código-fonte
│   └── db/           # Scripts SQL
├── frontend/         # App Next.js
│   ├── pages/        # Páginas (Pages Router)
│   └── components/   # Componentes React
├── infra/            # Infraestrutura
│   ├── terraform/    # AWS + Cloudflare
│   └── ansible/      # Deploy automation
└── .github/workflows/ # CI/CD
```

## 🚀 Como Executar

### Setup Inicial

```bash
# Gerar arquivo .env com credenciais seguras
make setup
```

### Com Make (Recomendado)

```bash
# Dev Local (hot-reload com volumes)
make dev-local

# Dev Container (build otimizado)
make dev-container

# Parar containers
make down

# Ver logs
make logs
```

### Com Docker Compose

```bash
# Dev Local
docker compose -f docker-compose-local.yml up

# Dev Container
docker compose -f docker-compose-container.yml up --build
```

**URLs:** Frontend [http://localhost:3000](http://localhost:3000) | Backend [http://localhost:3001/api](http://localhost:3001/api)

### Local (sem Docker)

```bash
# Instalar dependências
make install

# Backend
cd backend && npm run start:dev

# Frontend
cd frontend && npm run dev
```

## 📡 Endpoints Principais

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/auth/login` | Login JWT | Não |
| GET | `/products` | Listar produtos | Não |
| POST | `/products` | Criar produto | JWT |
| PUT | `/products/:id` | Atualizar produto | JWT |
| DELETE | `/products/:id` | Remover produto | JWT |

**Query params:** `?search=nome&sortBy=price&order=asc`

Documentação completa: [ENDPOINTS.md](ENDPOINTS.md)

## 🧪 Testes

```bash
cd backend && npm test        # Testes unitários
cd backend && npm run test:cov # Cobertura
```

---

## 🤖 Uso de IA - Documentação

### Prompts e Decisões

#### 1. Setup Inicial - Package.json e Dependências

**Prompt:**
> "Estruturar package.json do front e back baseado nas versões dos Dockerfiles. Adicione todas dependências necessárias e teste localmente validando versões entre local e Docker."

**Intervenção:**
> "Não seria melhor fazer lock na versão do node/npm para evitar quebra de dependências?"

**Decisão:** ✅ Versões exatas (sem ^ ou ~) em todos os package.json
**Justificativa:** Garantir reprodutibilidade e evitar "dependency hell"

---

#### 2. Linting e Formatação

**Tentativa da IA:** Criar `.prettierrc`

**Intervenção:**
> "Certifique-se que os padrões de linting não sobrescrevem o padrão do template"

**Decisão:** ❌ Prettier rejeitado, mantido apenas `.eslintrc.js` existente
**Justificativa:** Preservar consistência com template original

---

#### 3. Estrutura do Frontend

**Problema:** Conflito entre `pages/` (template) e `src/app/` (criado pela IA)

**Intervenção:**
> "A estrutura original deve ser mantida, adapte para usar pages antiga"

**Decisão:** ❌ App Router rejeitado, ✅ Pages Router mantido
**Justificativa:** Respeitar arquitetura do template, evitar refatoração desnecessária

---

#### 4. Docker de Produção

**Prompt:**
> "Faça docker-compose-container.yml que utilize Dockerfiles ao invés do npm e instale versão local do node 18"

**Decisão:** ✅ Multi-stage builds + Alpine Linux + .nvmrc + script install-node18.sh
**Justificativa:** Otimização de imagens Docker e consistência de versão Node

**Problema encontrado:** Pasta `public/` ausente causou erro no build
**Solução:** Criação de `public/` vazia

---

#### 5. Gitignore

**Prompt:**
> "Adicione gitignore para esconder arquivos de compilação"

**Problema:** Builds do Docker com permissões root conflitavam com builds locais

**Decisão:** ✅ Adicionar `dist.*/` e `.next.*/` ao gitignore
**Justificativa:** Separar builds Docker/local evita conflitos de permissão

---

#### 6. Testes e Validação

**Prompt:**
> "Teste ambos fluxos dos containers e local com build e start"

**Problemas resolvidos:**

- Permissões de arquivos → Renomear pastas ao invés de deletar
- Build interrompido → Reexecutado com sucesso

**Decisão:** ✅ ENDPOINTS.md criado, ❌ SETUP.md separado rejeitado
**Justificativa:** Evitar duplicação, centralizar documentação

---

### Resumo

| Item | Status | Motivo |
|------|--------|--------|
| Versões fixadas | ✅ Aceito | Reprodutibilidade |
| App Router Next.js | ❌ Rejeitado | Manter template |
| Multi-stage Docker | ✅ Aceito | Otimização |
| Prettier config | ❌ Rejeitado | Evitar conflitos |
| ENDPOINTS.md | ✅ Aceito | Clareza |

**Estatísticas:** 7 prompts principais | 5 intervenções manuais | 20+ arquivos criados | 100% builds ✅

---

### Ferramentas de IA Utilizadas

#### Sessões 1-10: Claude Code 4.5 Sonnet (Interface terminal integrada a extensão vscode)

**Período:** 2025-10-20 a 2025-10-22 (Sessões 1-10)

**Escopo:**

- ✅ Setup inicial do projeto
- ✅ Configuração de ambiente e dependências
- ✅ Implementação Backend (NestJS) e Frontend (Next.js)
- ✅ Docker e Docker Compose
- ✅ Correções de bugs (upload, login, imagens)
- ✅ Infraestrutura completa (Terraform + Ansible + Traefik)
- ✅ CI/CD (GitHub Actions)
- ✅ Documentação extensiva

**Características:**

- Bom para planejamento e arquitetura
- Explicações detalhadas e didáticas
- Documentação completa
- Menos integração com ferramentas de desenvolvimento

**Resultado:** Base completa do projeto implementada

---

#### Sessão 11: GitHub Copilot nativo + modelo Claude 4.5 Sonnet (VS Code)

**Período:** 2025-10-22 (Sessão 11)

**Escopo:**

- ✅ Correção de nomes de imagens Docker (lowercase)
- ✅ Trigger automático de deploy (workflow_run)
- ✅ Healthchecks otimizados (start_period, retries)
- ✅ Resource limits para prevenir timeout SSH
- ✅ Registro de AppController/AppService no AppModule
- ✅ Healthcheck com busybox wget (Alpine Linux)
- ✅ Debug tasks no playbook Ansible

**Características:**

- Integração perfeita com VS Code
- Ferramentas de edição de código muito precisas
- Contexto completo do workspace
- Acesso direto a Git e terminal
- Validação exata de mudanças de código

**Resultado:** Deploy de produção funcionando completamente

---

**Documentação Completa:** Ver [docs/PROMPTS.md](docs/PROMPTS.md) para histórico detalhado de todas as 11 sessões.

---

## 📝 Commits Semânticos

```plaintext
feat: add Docker and Docker Compose configurations
feat: add initial frontend configuration and styling files
docs: add comprehensive ENDPOINTS documentation
chore: add .gitignore and Node 18 setup files
fix: corrige deploy com imagens do GHCR e healthchecks
fix: registra AppController no AppModule e corrige healthcheck
```

## 🌿 Branch de Entrega

Branch: `submission/final`

```bash
git checkout -b submission/final
git push origin submission/final
```

---

## 🔧 Troubleshooting

### Problema: Backend container unhealthy

**Sintoma:** Deploy falha com container `hortti-backend-prod` unhealthy após 5+ minutos

**Causa:** Endpoint `/api/health` retorna 404 porque `AppController` não estava registrado no `AppModule`

**Solução:**

```typescript
// backend/src/app.module.ts
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  controllers: [AppController],
  providers: [AppService],
})
```

**Healthcheck corrigido para Alpine Linux:**

```yaml
# docker-compose-prod.yml
healthcheck:
  test: ["CMD-SHELL", "wget --spider -q http://localhost:3001/api/health || exit 1"]
```

**Resultado:** Container healthy em 16.3s

---

### Problema: Imagens não exibidas

**Sintoma:** Ícone genérico de imagem quebrada aparece após upload

**Causa:** Frontend usa URLs relativas (`/uploads/...`) que apontam para `localhost:3000` ao invés de `localhost:3001`

**Solução:** Implementada função `getImageUrl()` que converte URLs relativas em absolutas:

```typescript
// frontend/lib/api.ts
export function getImageUrl(imageUrl: string | null | undefined): string | null {
  if (!imageUrl) return null;
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  return `${BASE_URL}${imageUrl}`; // http://localhost:3001/uploads/...
}
```

**Arquivos modificados:**

- [lib/api.ts](frontend/lib/api.ts#L13-L19)
- [pages/products/index.tsx](frontend/pages/products/index.tsx#L127)
- [pages/products/[id]/edit.tsx](frontend/pages/products/[id]/edit.tsx#L77)

---### Problema: Login com credenciais padrão não funciona

**Sintoma:** Erro 401 ao tentar fazer login com `admin@cantinhoverde.com` / `Admin@123`

**Causa:** Hashes bcrypt hardcoded no init.sql estavam desatualizados

**Solução:** Sistema automatizado de geração de hashes via `generate-env.sh`:

```bash
# Gera .env com hashes bcrypt automaticamente
bash generate-env.sh

# Reinicia banco com novos hashes
docker compose -f docker-compose-local.yml down -v
docker compose -f docker-compose-local.yml up --build
```

**Credenciais padrão:**

- Admin: `admin@cantinhoverde.com` / `Admin@123`
- User: `user@cantinhoverde.com` / `User@123`

### Problema: Upload de arquivo retorna `undefined`

**Sintoma:** URL salva no banco como `/uploads/undefined`

**Causa:** Multer não estava configurado corretamente para usar path absoluto

**Solução:** Ajustada configuração do Multer em [upload.module.ts](backend/src/upload/upload.module.ts#L15-L19):

```typescript
destination: (req, file, cb) => {
  const uploadPath = configService.get<string>('UPLOAD_DEST', './uploads');
  const absolutePath = uploadPath.startsWith('/') ? uploadPath : join(process.cwd(), uploadPath);
  cb(null, absolutePath);
}
```

### Secrets Gerenciados pelo Terraform

**Reduzido de 15+ para apenas 5 GitHub Secrets obrigatórios:**

Terraform gera automaticamente:

- SSH keys (RSA 4096)
- PostgreSQL password (32 chars)
- JWT secret + refresh (64 chars cada)
- Backup em AWS SSM Parameter Store

**Secrets necessários:**

1. `AWS_ACCESS_KEY_ID`
2. `AWS_SECRET_ACCESS_KEY`
3. `CLOUDFLARE_API_TOKEN`
4. `CLOUDFLARE_ZONE_ID`
5. `GITHUBS_TOKEN`

Ver: [docs/GITHUB_SECRETS.md](docs/GITHUB_SECRETS.md)

### Terraform Backend Bootstrap

**Primeira vez:** Terraform backend (S3 + DynamoDB) criado automaticamente

O script `infra/terraform/bootstrap-backend.sh` cria:

- S3 bucket: `hortti-terraform-state` (versionamento + encryption)
- DynamoDB table: `hortti-terraform-locks` (state locking)

**Custo:** < $1/mês | **Região:** us-east-2

Ver: [infra/terraform/BOOTSTRAP.md](infra/terraform/BOOTSTRAP.md)

---

## 🚀 Deploy em Produção

### Infraestrutura

**Compute:**

- AWS EC2 t2.medium (us-east-2)
- Ubuntu 22.04 LTS
- Docker + Docker Compose

**Network:**

- VPC customizado (10.0.0.0/16)
- Subnet pública (10.0.1.0/24)
- Internet Gateway + Route Table
- Security Group (SSH, HTTP, HTTPS)
- Elastic IP

**Automation:**

- IaC: Terraform (21 recursos)
- Config: Ansible
- CI/CD: GitHub Actions
- DNS: Cloudflare
- SSL: Let's Encrypt (Traefik)
- Registry: GitHub Container Registry (GHCR)

### Domínios

- **Frontend:** <https://cantinhoverde.app.br>
- **Backend:** <https://api.cantinhoverde.app.br>
- **Traefik Dashboard:** <https://traefik.cantinhoverde.app.br>

### Quick Deploy

```bash
# 1. Setup inicial (uma vez)
make complete-setup

# 2. Configurar variáveis
vim infra/terraform/terraform.tfvars
vim infra/ansible/vars/secrets.yml

# 3. Provisionar infraestrutura
make infra-plan
make infra-apply

# 4. Deploy da aplicação
make prod-deploy
```

### Documentação Completa

- [Guia de Deploy](docs/DEPLOYMENT.md) - Instruções completas
- [GitHub Secrets](docs/SECRETS.md) - Configuração de CI/CD
- [Endpoints API](docs/ENDPOINTS.md) - Documentação da API

### Comandos Úteis

```bash
# Infraestrutura
make infra-plan          # Planejar mudanças
make infra-apply         # Aplicar infraestrutura
make infra-output        # Ver outputs (IPs, URLs)

# Deploy
make deploy              # Deploy com Ansible
make deploy-check        # Verificar conectividade

# Produção
make prod-status         # Status dos containers
make prod-logs           # Logs em tempo real
make prod-restart        # Reiniciar aplicação

# Docker Images
make docker-build-push   # Build e push para GHCR
```

---

## 📧 Contato

Repositório compartilhado com @cassiowt conforme solicitado.
