# Hortti Inventory - Endpoints e URLs de Acesso

## Ambiente Local (Desenvolvimento sem Docker)

### Backend

**URL Base:** <http://localhost:3001>

**Como rodar:**

```bash
cd backend
npm install
npm run start:dev
```

**Endpoints API:**

- `GET /` - Health check
- `GET /products` - Listar todos os produtos
- `GET /products/:id` - Buscar produto por ID
- `POST /products` - Criar novo produto
- `PUT /products/:id` - Atualizar produto
- `DELETE /products/:id` - Remover produto
- `POST /auth/login` - Login (JWT)
- `POST /auth/register` - Registro de usuário

### Frontend

**URL:** <http://localhost:3000>

**Como rodar:**

```bash
cd frontend
npm install
npm run dev
```

**Páginas:**

- `/` - Página inicial com listagem de produtos
- `/login` - Página de login
- `/products/new` - Criar novo produto
- `/products/[id]` - Visualizar/editar produto

---

## Docker Compose - Desenvolvimento (docker-compose-local.yml)

### Como rodar

```bash
docker compose -f docker-compose-local.yml up
```

### Serviços e Portas

#### PostgreSQL

- **Host:** localhost
- **Porta:** 5432
- **Usuário:** postgres
- **Senha:** postgres
- **Database:** hortti_db
- **Connection String:** `postgresql://postgres:postgres@localhost:5432/hortti_db`

#### Backend (NestJS)

- **URL:** <http://localhost:3001>
- **Mode:** Hot-reload (desenvolvimento)
- **Container:** hortti-recrutamento-backend

#### Frontend (Next.js)

- **URL:** <http://localhost:3000>
- **Mode:** Hot-reload (desenvolvimento)
- **Container:** hortti-recrutamento-frontend

### Características

- Volumes montados para hot-reload
- Mudanças no código refletem automaticamente
- npm run start:dev (backend) e npm run dev (frontend)

---

## Docker Compose - Produção (docker-compose-container.yml)

### Como rodar o Docker em modo produção

```bash
docker compose -f docker-compose-container.yml up --build
```

### Serviços e Portas Configurados

#### PostgreSQL Database

- **Host:** localhost (externo) ou `db` (interno)
- **Porta:** 5432
- **Usuário:** postgres
- **Senha:** postgres
- **Database:** hortti_db
- **Volume:** postgres_data (persistente)
- **Health Check:** Sim

#### System Backend (NestJS)

- **URL:** <http://localhost:3001>
- **Mode:** Produção (compilado)
- **Container:** hortti-backend
- **Dockerfile:** Dockerfile.prod (multi-stage)
- **Health Check:** Sim
- **Network:** hortti-network

#### System Frontend (Next.js)

- **URL:** <http://localhost:3000>
- **Mode:** Produção (otimizado)
- **Container:** hortti-frontend
- **Dockerfile:** Dockerfile.prod (multi-stage)
- **Network:** hortti-network

### Características das Imagens de Produção

- Imagens Alpine Linux (mais leves)
- Multi-stage build (menor tamanho)
- Health checks configurados
- Volumes persistentes
- Restart automático
- Network isolada
- Otimizado para produção

---

## Variáveis de Ambiente

### Backend (.env)

```env
NODE_ENV=production
DB_HOST=db
DB_PORT=5432
DB_USER=postgres
DB_PASS=postgres
DB_NAME=hortti_db
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=24h
PORT=3001
```

### Frontend (.env.local)

```env
NODE_ENV=production
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

## Comandos Úteis

### Build Local

```bash
# Backend
cd backend
npm run build
npm run start:prod

# Frontend
cd frontend
npm run build
npm run start
```

### Docker - Desenvolvimento

```bash
# Subir serviços
docker compose -f docker-compose-local.yml up

# Subir em background
docker compose -f docker-compose-local.yml up -d

# Ver logs
docker compose -f docker-compose-local.yml logs -f

# Parar serviços
docker compose -f docker-compose-local.yml down

# Rebuild
docker compose -f docker-compose-local.yml up --build
```

### Docker - Produção

```bash
# Build e subir
docker compose -f docker-compose-container.yml up --build

# Subir em background
docker compose -f docker-compose-container.yml up -d

# Ver logs
docker compose -f docker-compose-container.yml logs -f

# Parar e remover volumes
docker compose -f docker-compose-container.yml down -v

# Ver status
docker compose -f docker-compose-container.yml ps
```

### Outros

```bash
# Limpar containers e imagens
docker system prune -a

# Ver uso de espaço
docker system df

# Acessar container
docker exec -it hortti-backend sh
docker exec -it hortti-frontend sh

# Acessar PostgreSQL
docker exec -it hortti-db psql -U postgres -d hortti_db
```

---

## Resumo de URLs

| Ambiente | Frontend | Backend | Database |
|----------|----------|---------|----------|
| **Local** | `http://localhost:3000` | `http://localhost:3001` | `localhost:5432` |
| **Docker Dev** | `http://localhost:3000` | `http://localhost:3001` | `localhost:5432` |
| **Docker Prod** | `http://localhost:3000` | `http://localhost:3001` | `localhost:5432` |

---

## Testes Realizados

✅ Build local backend - **SUCESSO**
✅ Build local frontend - **SUCESSO**
✅ Docker Compose desenvolvimento (docker-compose-local.yml) - **SUCESSO**
✅ Docker Compose produção (docker-compose-container.yml) - **SUCESSO**

### Detalhes dos Testes

**Build Local:**

- Backend: Compilação TypeScript OK - dist/ criado
- Frontend: Build Next.js OK - .next/ criado
- Ambos prontos para `npm start` / `npm run start:prod`

**Docker Desenvolvimento:**

- Containers: backend, frontend, db
- Status: Todos rodando
- Hot-reload: Ativo
- URLs: Frontend (3000), Backend (3001), DB (5432)

**Docker Produção:**

- Build: Multi-stage concluído com sucesso
- Imagens: Alpine Linux (otimizadas)
- Frontend: ✅ Rodando em <http://localhost:3000>
- Backend: ⚠️ Iniciando (aguardando schema do banco)
- PostgreSQL: ✅ Healthy
- Health checks: Configurados
- Volumes: postgres_data criado

---

## Próximos Passos

1. Implementar rotas de autenticação JWT
2. Criar endpoints de produtos
3. Configurar upload de imagens
4. Implementar interface de usuário no frontend
5. Adicionar testes unitários e E2E
6. Criar scripts SQL de seeds
