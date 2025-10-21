# Hortti Inventory

Sistema fullstack para gestão de inventário do "Cantinho Verde" com NestJS, Next.js, PostgreSQL e Docker.

## 🛠️ Tecnologias

**Backend:** NestJS 10.3 | TypeScript 5.3 | TypeORM | PostgreSQL 15 | JWT | Multer
**Frontend:** Next.js 14.0 | React 18.2 | TypeScript 5.3 | Tailwind CSS 3.4 | Axios | SWR
**DevOps:** Docker | Docker Compose | Node.js 18

## 📁 Estrutura

```text
├── backend/          # API NestJS
│   ├── src/          # Código-fonte
│   └── db/           # Scripts SQL
├── frontend/         # App Next.js
│   ├── pages/        # Páginas (Pages Router)
│   └── components/   # Componentes React
└── docker-compose-*.yml
```

## 🚀 Como Executar

### Com Docker (Recomendado)

```bash
# Desenvolvimento (hot-reload)
docker compose -f docker-compose-local.yml up

# Produção (otimizado)
docker compose -f docker-compose-container.yml up --build
```

**URLs:** Frontend [http://localhost:3000](http://localhost:3000) | Backend [http://localhost:3001](http://localhost:3001)

### Local (sem Docker)

```bash
# Backend
cd backend && npm install && npm run start:dev

# Frontend
cd frontend && npm install && npm run dev
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

## 📝 Commits Semânticos

```plaintext
feat: add Docker and Docker Compose configurations
feat: add initial frontend configuration and styling files
docs: add comprehensive ENDPOINTS documentation
chore: add .gitignore and Node 18 setup files
```

## 🌿 Branch de Entrega

Branch: `submission/final`

```bash
git checkout -b submission/final
git push origin submission/final
```

## 📧 Contato

Repositório compartilhado com @cassiowt conforme solicitado.
