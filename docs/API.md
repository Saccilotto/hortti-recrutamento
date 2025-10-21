# API Documentation - Hortti Inventory

> Documentação completa da API REST do sistema de gestão de inventário

## Base URL

```text
http://localhost:3001/api
```

## Índice

- [Autenticação](#autenticação)
- [Produtos](#produtos)
- [Upload de Imagens](#upload-de-imagens)
- [Códigos de Status](#códigos-de-status)
- [Erros](#erros)

---

## Autenticação

Todos os endpoints protegidos requerem um token JWT no header:

```http
Authorization: Bearer {token}
```

### POST /auth/register

Registra um novo usuário no sistema.

**Request:**
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "usuario@example.com",
  "password": "senha123",
  "name": "Nome do Usuário",
  "role": "user"
}
```

**Validações:**
- `email`: Email válido, obrigatório
- `password`: Mínimo 6 caracteres, obrigatório
- `name`: Mínimo 3 caracteres, máximo 255, obrigatório
- `role`: "admin" ou "user", opcional (padrão: "user")

**Response 201:**
```json
{
  "message": "Usuário registrado com sucesso",
  "user": {
    "id": 1,
    "email": "usuario@example.com",
    "name": "Nome do Usuário",
    "role": "user",
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T12:00:00.000Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 409:**
```json
{
  "statusCode": 409,
  "message": "Email já cadastrado",
  "error": "Conflict"
}
```

---

### POST /auth/login

Faz login do usuário e retorna um token JWT.

**Request:**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@cantinhoverde.com",
  "password": "Admin@123"
}
```

**Response 200:**
```json
{
  "message": "Login realizado com sucesso",
  "user": {
    "id": 1,
    "email": "admin@cantinhoverde.com",
    "name": "Administrador",
    "role": "admin",
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T12:00:00.000Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 401:**
```json
{
  "statusCode": 401,
  "message": "Credenciais inválidas",
  "error": "Unauthorized"
}
```

---

### GET /auth/me

Retorna dados do usuário autenticado.

**Request:**
```http
GET /api/auth/me
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "user": {
    "id": 1,
    "email": "admin@cantinhoverde.com",
    "name": "Administrador",
    "role": "admin",
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T12:00:00.000Z"
  }
}
```

---

### GET /auth/verify

Verifica se o token JWT é válido.

**Request:**
```http
GET /api/auth/verify
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "valid": true,
  "user": {
    "sub": 1,
    "email": "admin@cantinhoverde.com",
    "role": "admin"
  }
}
```

---

## Produtos

### GET /products

Lista todos os produtos com suporte a busca, filtros, ordenação e paginação.

**Público:** Não requer autenticação

**Query Parameters:**

| Parâmetro | Tipo | Descrição | Padrão |
|-----------|------|-----------|--------|
| `search` | string | Busca por nome (case-insensitive) | - |
| `category` | string | Filtro por categoria: fruta, verdura, legume | - |
| `sortBy` | string | Campo para ordenação: name, price, createdAt | createdAt |
| `order` | string | Ordem: ASC ou DESC | DESC |
| `page` | number | Número da página | 1 |
| `limit` | number | Itens por página | 10 |

**Request:**
```http
GET /api/products?search=tomate&category=legume&sortBy=price&order=ASC&page=1&limit=10
```

**Response 200:**
```json
{
  "data": [
    {
      "id": 14,
      "name": "Tomate Italiano",
      "category": "legume",
      "price": "5.50",
      "imageUrl": "/uploads/abc123.jpg",
      "description": "Tomate italiano maduro",
      "stock": 100,
      "isActive": true,
      "createdAt": "2025-10-21T12:00:00.000Z",
      "updatedAt": "2025-10-21T12:00:00.000Z"
    },
    {
      "id": 15,
      "name": "Tomate Cereja",
      "category": "legume",
      "price": "8.90",
      "imageUrl": null,
      "description": "Tomate cereja doce",
      "stock": 70,
      "isActive": true,
      "createdAt": "2025-10-21T12:00:00.000Z",
      "updatedAt": "2025-10-21T12:00:00.000Z"
    }
  ],
  "meta": {
    "total": 2,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

---

### GET /products/:id

Busca um produto específico por ID.

**Público:** Não requer autenticação

**Request:**
```http
GET /api/products/1
```

**Response 200:**
```json
{
  "product": {
    "id": 1,
    "name": "Banana Prata",
    "category": "fruta",
    "price": "3.99",
    "imageUrl": "/uploads/banana.jpg",
    "description": "Banana prata fresca, doce e nutritiva",
    "stock": 150,
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T12:00:00.000Z"
  }
}
```

**Response 404:**
```json
{
  "statusCode": 404,
  "message": "Produto #999 não encontrado",
  "error": "Not Found"
}
```

---

### POST /products

Cria um novo produto.

**Autenticação:** Requerida (JWT)

**Request:**
```http
POST /api/products
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Abóbora Cabotiá",
  "category": "legume",
  "price": 4.50,
  "description": "Abóbora cabotiá fresca",
  "stock": 50,
  "imageUrl": "/uploads/abobora.jpg"
}
```

**Validações:**
- `name`: String, obrigatório, máximo 255 caracteres
- `category`: Enum "fruta", "verdura" ou "legume", obrigatório
- `price`: Número >= 0, máximo 2 casas decimais, obrigatório
- `description`: String, opcional, máximo 1000 caracteres
- `stock`: Inteiro >= 0, opcional
- `imageUrl`: String, opcional

**Response 201:**
```json
{
  "message": "Produto criado com sucesso",
  "product": {
    "id": 36,
    "name": "Abóbora Cabotiá",
    "category": "legume",
    "price": "4.50",
    "imageUrl": "/uploads/abobora.jpg",
    "description": "Abóbora cabotiá fresca",
    "stock": 50,
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T12:00:00.000Z"
  }
}
```

**Response 400:**
```json
{
  "statusCode": 400,
  "message": [
    "Categoria deve ser: fruta, verdura ou legume",
    "Preço não pode ser negativo"
  ],
  "error": "Bad Request"
}
```

---

### PATCH /products/:id

Atualiza um produto existente (parcial).

**Autenticação:** Requerida (JWT)

**Request:**
```http
PATCH /api/products/1
Authorization: Bearer {token}
Content-Type: application/json

{
  "price": 4.99,
  "stock": 200
}
```

**Response 200:**
```json
{
  "message": "Produto atualizado com sucesso",
  "product": {
    "id": 1,
    "name": "Banana Prata",
    "category": "fruta",
    "price": "4.99",
    "imageUrl": "/uploads/banana.jpg",
    "description": "Banana prata fresca, doce e nutritiva",
    "stock": 200,
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T13:30:00.000Z"
  }
}
```

---

### DELETE /products/:id

Remove um produto permanentemente do banco de dados.

**Autenticação:** Requerida (JWT)

**Request:**
```http
DELETE /api/products/1
Authorization: Bearer {token}
```

**Response 204:**
```
No Content
```

**Nota:** A imagem associada ao produto também será deletada.

---

### PATCH /products/:id/image

Atualiza a imagem de um produto.

**Autenticação:** Requerida (JWT)

**Request:**
```http
PATCH /api/products/1/image
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [arquivo binário]
```

**Response 200:**
```json
{
  "message": "Imagem atualizada com sucesso",
  "product": {
    "id": 1,
    "name": "Banana Prata",
    "category": "fruta",
    "price": "3.99",
    "imageUrl": "/uploads/abc123def456.jpg",
    "description": "Banana prata fresca, doce e nutritiva",
    "stock": 150,
    "isActive": true,
    "createdAt": "2025-10-21T12:00:00.000Z",
    "updatedAt": "2025-10-21T13:45:00.000Z"
  }
}
```

**Nota:** A imagem anterior será deletada automaticamente.

---

## Upload de Imagens

### POST /upload/image

Faz upload de uma imagem.

**Autenticação:** Requerida (JWT)

**Request:**
```http
POST /api/upload/image
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [arquivo binário]
```

**Restrições:**
- Formatos permitidos: JPEG, JPG, PNG, WEBP
- Tamanho máximo: 5MB

**Response 200:**
```json
{
  "message": "Imagem enviada com sucesso",
  "filename": "abc123def456.jpg",
  "imageUrl": "/uploads/abc123def456.jpg"
}
```

**Response 400:**
```json
{
  "statusCode": 400,
  "message": "Nenhum arquivo foi enviado",
  "error": "Bad Request"
}
```

---

### DELETE /upload/:filename

Deleta uma imagem do servidor.

**Autenticação:** Requerida (JWT)

**Request:**
```http
DELETE /api/upload/abc123def456.jpg
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "message": "Imagem deletada com sucesso"
}
```

---

## Códigos de Status

| Código | Descrição |
|--------|-----------|
| 200 | OK - Requisição bem-sucedida |
| 201 | Created - Recurso criado com sucesso |
| 204 | No Content - Requisição bem-sucedida sem corpo de resposta |
| 400 | Bad Request - Dados inválidos |
| 401 | Unauthorized - Não autenticado |
| 403 | Forbidden - Sem permissão |
| 404 | Not Found - Recurso não encontrado |
| 409 | Conflict - Conflito (ex: email duplicado) |
| 500 | Internal Server Error - Erro do servidor |

---

## Erros

Todas as respostas de erro seguem o padrão:

```json
{
  "statusCode": 400,
  "message": "Mensagem de erro ou array de mensagens",
  "error": "Tipo do erro"
}
```

**Exemplos:**

```json
{
  "statusCode": 400,
  "message": [
    "Email inválido",
    "Senha deve ter no mínimo 6 caracteres"
  ],
  "error": "Bad Request"
}
```

```json
{
  "statusCode": 401,
  "message": "Credenciais inválidas",
  "error": "Unauthorized"
}
```

---

## Exemplos de Uso

### Fluxo Completo: Criar Produto com Imagem

**1. Login:**
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@cantinhoverde.com","password":"Admin@123"}'
```

**2. Upload da Imagem:**
```bash
curl -X POST http://localhost:3001/api/upload/image \
  -H "Authorization: Bearer {token}" \
  -F "file=@produto.jpg"
```

**3. Criar Produto:**
```bash
curl -X POST http://localhost:3001/api/products \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Produto Novo",
    "category": "fruta",
    "price": 5.99,
    "imageUrl": "/uploads/abc123.jpg",
    "stock": 100
  }'
```

**4. Atualizar Produto:**
```bash
curl -X PATCH http://localhost:3001/api/products/36 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"price": 6.50}'
```

**5. Deletar Produto:**
```bash
curl -X DELETE http://localhost:3001/api/products/36 \
  -H "Authorization: Bearer {token}"
```

---

## Variáveis de Ambiente

Configurações disponíveis no arquivo `.env`:

```env
PORT=3001
JWT_SECRET=seu-secret-aqui
JWT_EXPIRATION=1d
CORS_ORIGIN=http://localhost:3000
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=hortti_inventory
UPLOAD_DEST=./uploads
UPLOAD_MAX_FILE_SIZE=5242880
```

---

**Versão:** 1.0.0
**Última atualização:** 2025-10-21
