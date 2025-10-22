# Hortti Inventory - Backend

> API REST em NestJS para gestão de inventário do Cantinho Verde

## Tecnologias

- **Framework:** NestJS 10.3
- **Linguagem:** TypeScript 5.3
- **Banco de Dados:** PostgreSQL 15
- **ORM:** TypeORM 0.3
- **Autenticação:** JWT (Passport)
- **Validação:** class-validator
- **Upload:** Multer
- **Hash:** bcrypt

## Estrutura do Projeto

```text
backend/
├── src/
│   ├── auth/              # Módulo de autenticação JWT
│   │   ├── guards/        # Guards (JWT, Local, Roles)
│   │   ├── strategies/    # Passport strategies
│   │   ├── decorators/    # Decorators customizados
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.module.ts
│   ├── products/          # Módulo de produtos
│   │   ├── products.controller.ts
│   │   ├── products.service.ts
│   │   └── products.module.ts
│   ├── upload/            # Módulo de upload de imagens
│   │   ├── upload.controller.ts
│   │   ├── upload.service.ts
│   │   └── upload.module.ts
│   ├── entities/          # Entidades TypeORM
│   │   ├── user.entity.ts
│   │   ├── product.entity.ts
│   │   └── index.ts
│   ├── dto/               # Data Transfer Objects
│   │   ├── auth/
│   │   ├── product/
│   │   └── index.ts
│   ├── validators/        # Validators customizados
│   ├── app.module.ts
│   └── main.ts
├── db/                    # Scripts de banco de dados
│   ├── init.sql           # Schema + seeds
│   ├── test-connection.sh
│   └── README.md
├── uploads/               # Diretório de imagens (criado automaticamente)
├── .env.example
├── package.json
├── API.md                 # Documentação da API
└── README.md
```

## Instalação

### Pré-requisitos

- Node.js 18.x
- npm 9.x
- PostgreSQL 15

### Passo a Passo

**1. Instalar dependências:**

```bash
cd backend
npm install
```

**2. Configurar variáveis de ambiente:**

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:

```env
PORT=3001
JWT_SECRET=seu-secret-super-seguro-aqui
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=hortti_inventory
```

**3. Criar banco de dados:**

```bash
# Conectar ao PostgreSQL
psql -U postgres

# Criar database
CREATE DATABASE hortti_inventory;

# Executar script de inicialização
\i db/init.sql

# Sair
\q
```

Ou use Docker (veja seção Docker abaixo).

**4. Executar aplicação:**

```bash
# Desenvolvimento (hot-reload)
npm run start:dev

# Produção
npm run build
npm run start:prod
```

A API estará disponível em [http://localhost:3001/api](http://localhost:3001/api)

---

## Docker

### Com Docker Compose (Recomendado)

**Desenvolvimento:**

```bash
# Na raiz do projeto
docker compose -f docker-compose-local.yml up
```

**Produção:**

```bash
# Na raiz do projeto
docker compose -f docker-compose-container.yml up --build
```

### Testar Conexão com Banco

```bash
# Rodar script de teste
./db/test-connection.sh

# Ou com variáveis customizadas
DB_HOST=localhost DB_PORT=5432 ./db/test-connection.sh
```

---

## Scripts Disponíveis

```bash
# Desenvolvimento
npm run start:dev          # Inicia com hot-reload
npm run start:debug        # Inicia com debugger

# Build
npm run build              # Compila TypeScript

# Produção
npm run start:prod         # Executa versão compilada

# Testes
npm test                   # Roda testes unitários
npm run test:cov           # Roda testes com cobertura
npm run test:e2e           # Roda testes e2e

# Linting
npm run lint               # Verifica código
npm run format             # Formata código
```

---

## Endpoints Principais

### Autenticação

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/api/auth/register` | Registrar usuário | Não |
| POST | `/api/auth/login` | Login | Não |
| GET | `/api/auth/me` | Dados do usuário | JWT |
| GET | `/api/auth/verify` | Verificar token | JWT |

### Produtos

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| GET | `/api/products` | Listar produtos | Não |
| GET | `/api/products/:id` | Buscar produto | Não |
| POST | `/api/products` | Criar produto | JWT |
| PATCH | `/api/products/:id` | Atualizar produto | JWT |
| DELETE | `/api/products/:id` | Deletar produto | JWT |
| PATCH | `/api/products/:id/image` | Atualizar imagem | JWT |

### Upload

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/api/upload/image` | Upload de imagem | JWT |
| DELETE | `/api/upload/:filename` | Deletar imagem | JWT |

**Documentação completa:** Veja [API.md](API.md)

---

## Funcionalidades

### Autenticação JWT

- Registro de usuários com hash bcrypt
- Login com geração de token JWT
- Proteção de rotas com guards
- Validação de token
- Roles (admin/user)

### CRUD de Produtos

- Listagem com paginação
- Busca por nome (case-insensitive)
- Filtro por categoria (fruta/verdura/legume)
- Ordenação por nome/preço/data
- Upload e atualização de imagens
- Validação completa de dados

### Upload de Imagens

- Formatos aceitos: JPEG, PNG, WEBP
- Tamanho máximo: 5MB
- Nomes aleatórios para evitar conflitos
- Deleção automática ao remover produto
- Servir arquivos estáticos

### Segurança

- Senhas hasheadas com bcrypt
- Tokens JWT com expiração
- Validação de entrada com class-validator
- CORS configurável
- Sanitização de dados

---

## Testes

### Credenciais de Teste

**Admin:**

```text
Email: admin@cantinhoverde.com
Senha: Admin@123
```

**User:**

```text
Email: user@cantinhoverde.com
Senha: User@123

```text
Email: user@cantinhoverde.com
Senha: User@123
```

### Exemplo de Teste com cURL

**1. Login:**

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@cantinhoverde.com","password":"Admin@123"}'
```

**2. Listar Produtos:**

```bash
curl http://localhost:3001/api/products?search=tomate&sortBy=price&order=ASC
```

**3. Criar Produto (com token):**

```bash
curl -X POST http://localhost:3001/api/products \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Melão",
    "category": "fruta",
    "price": 8.50,
    "stock": 30
  }'
```

---

## Configuração de Ambiente

### Variáveis de Ambiente (.env)

```env
# Aplicação
PORT=3001
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=hortti_inventory
DB_SYNCHRONIZE=false
DB_LOGGING=true

# JWT
JWT_SECRET=change-this-in-production
JWT_EXPIRATION=1d
JWT_REFRESH_SECRET=change-this-too
JWT_REFRESH_EXPIRATION=7d

# Bcrypt
BCRYPT_ROUNDS=10

# CORS
CORS_ORIGIN=http://localhost:3000

# Upload
UPLOAD_DEST=./uploads
UPLOAD_MAX_FILE_SIZE=5242880
```

---

## Banco de Dados

### Schema

- **users:** Usuários do sistema
- **products:** Produtos do inventário

### Seeds

- 2 usuários (admin e user)
- 35 produtos (10 frutas, 10 verduras, 15 legumes)

Veja documentação completa em [db/README.md](db/README.md)

---

## Troubleshooting

### Porta já em uso

```bash
# Encontrar processo usando a porta 3001
lsof -i :3001

# Matar processo
kill -9 PID
```

### Erro de conexão com banco

```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Testar conexão
./db/test-connection.sh
```

### Erro de permissão em uploads

```bash
# Criar diretório de uploads
mkdir -p uploads

# Dar permissões
chmod 755 uploads
```

---

## Próximos Passos

- [ ] Implementar refresh tokens
- [ ] Adicionar Swagger/OpenAPI
- [ ] Implementar rate limiting
- [ ] Adicionar logs estruturados
- [ ] Implementar soft delete em produtos
- [ ] Adicionar testes unitários
- [ ] Adicionar testes e2e
- [ ] Implementar CI/CD

---

**Versão:** 1.0.0
**Última atualização:** 2025-10-21
**Autor:** Hortti Team
