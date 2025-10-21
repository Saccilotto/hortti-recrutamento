# Banco de Dados - Hortti Inventory

> Documentação completa do schema PostgreSQL para o sistema de gestão de inventário do Cantinho Verde

## Índice

- [Visão Geral](#visão-geral)
- [Schema do Banco](#schema-do-banco)
- [Tabelas](#tabelas)
- [Seeds de Dados](#seeds-de-dados)
- [Views](#views)
- [Como Usar](#como-usar)

---

## Visão Geral

**Database:** `hortti_inventory`
**SGBD:** PostgreSQL 15
**Charset:** UTF-8
**Timezone:** UTC

### Características

- 2 tabelas principais: `users` e `products`
- Triggers automáticos para `updated_at`
- Índices otimizados para busca e ordenação
- Constraints de validação
- 35 produtos de exemplo (10 frutas, 10 verduras, 15 legumes)
- 2 usuários de teste

---

## Schema do Banco

```sql
-- Estrutura simplificada
hortti_inventory
├── users (autenticação)
│   ├── id (SERIAL PRIMARY KEY)
│   ├── email (VARCHAR UNIQUE)
│   ├── password (VARCHAR - bcrypt)
│   ├── name (VARCHAR)
│   ├── role (VARCHAR)
│   └── timestamps
└── products (inventário)
    ├── id (SERIAL PRIMARY KEY)
    ├── name (VARCHAR)
    ├── category (VARCHAR - CHECK)
    ├── price (NUMERIC)
    ├── image_url (TEXT)
    ├── description (TEXT)
    ├── stock (INTEGER)
    └── timestamps
```

---

## Tabelas

### 1. Tabela `users`

**Descrição:** Armazena usuários do sistema para autenticação JWT

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | SERIAL | PRIMARY KEY | ID único do usuário |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Email de login |
| `password` | VARCHAR(255) | NOT NULL | Senha hasheada (bcrypt) |
| `name` | VARCHAR(255) | NOT NULL | Nome completo |
| `role` | VARCHAR(50) | DEFAULT 'user' | Papel: admin ou user |
| `is_active` | BOOLEAN | DEFAULT true | Usuário ativo/inativo |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Última atualização |

**Índices:**

- `idx_users_email` - Busca por email (login)
- `idx_users_active` - Filtro de usuários ativos

**Exemplo de Query:**

```sql
-- Buscar usuário por email
SELECT * FROM users WHERE email = 'admin@cantinhoverde.com';

-- Listar usuários ativos
SELECT id, name, email, role FROM users WHERE is_active = true;
```

---

### 2. Tabela `products`

**Descrição:** Armazena produtos do inventário (frutas, verduras e legumes)

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | SERIAL | PRIMARY KEY | ID único do produto |
| `name` | VARCHAR(255) | NOT NULL | Nome do produto |
| `category` | VARCHAR(50) | NOT NULL, CHECK | Categoria: fruta, verdura, legume |
| `price` | NUMERIC(10,2) | NOT NULL, >= 0 | Preço em reais (BRL) |
| `image_url` | TEXT | NULL | URL da imagem (local ou CDN) |
| `description` | TEXT | NULL | Descrição detalhada |
| `stock` | INTEGER | DEFAULT 0, >= 0 | Quantidade em estoque |
| `is_active` | BOOLEAN | DEFAULT true | Produto ativo/inativo |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | DEFAULT NOW() | Última atualização |

**Constraints:**

```sql
CHECK (category IN ('fruta', 'verdura', 'legume'))
CHECK (price >= 0)
CHECK (stock >= 0)
```

**Índices:**

- `idx_products_name` - Busca por nome (search)
- `idx_products_category` - Filtro por categoria
- `idx_products_price` - Ordenação por preço
- `idx_products_active` - Filtro de produtos ativos

**Exemplo de Queries:**

```sql
-- Buscar produtos por nome (LIKE)
SELECT * FROM products
WHERE name ILIKE '%tomate%' AND is_active = true;

-- Listar produtos por categoria ordenado por preço
SELECT * FROM products
WHERE category = 'fruta' AND is_active = true
ORDER BY price ASC;

-- Buscar produtos com estoque baixo
SELECT * FROM products
WHERE stock < 50 AND is_active = true;
```

---

## Seeds de Dados

### Usuários Padrão

| Email | Senha | Nome | Role |
|-------|-------|------|------|
| `admin@cantinhoverde.com` | `Admin@123` | Administrador | admin |
| `user@cantinhoverde.com` | `User@123` | Usuário Teste | user |

**Nota:** As senhas estão hasheadas com bcrypt (rounds: 10)

**Hash de exemplo:** `$2b$10$rZ5qYxK8vQ5ZQHj3yYxqxO5zK9L5QZKjYxQ5yYxqxO5zK9L5QZKjY`

### Produtos de Exemplo

**Total:** 35 produtos distribuídos em 3 categorias

#### Frutas (10 produtos)

- Banana Prata - R$ 3,99
- Maçã Fuji - R$ 6,50
- Laranja Pera - R$ 4,20
- Mamão Papaya - R$ 5,80
- Manga Palmer - R$ 7,90
- Abacaxi Pérola - R$ 8,50
- Melancia - R$ 12,00
- Uva Itália - R$ 9,90
- Morango - R$ 11,50
- Limão Taiti - R$ 2,80

#### Verduras (10 produtos)

- Alface Americana - R$ 2,50
- Alface Crespa - R$ 2,30
- Rúcula - R$ 3,20
- Couve Manteiga - R$ 2,80
- Acelga - R$ 3,50
- Espinafre - R$ 4,20
- Agrião - R$ 3,80
- Chicória - R$ 2,90
- Almeirão - R$ 2,70
- Repolho Verde - R$ 3,90

#### Legumes (15 produtos)

- Tomate Italiano - R$ 5,50
- Tomate Cereja - R$ 8,90
- Batata Inglesa - R$ 3,80
- Batata Doce - R$ 4,50
- Cenoura - R$ 3,20
- Cebola - R$ 4,90
- Alho - R$ 25,00
- Pimentão Verde - R$ 6,80
- Pimentão Vermelho - R$ 7,50
- Abobrinha - R$ 4,20
- Berinjela - R$ 5,90
- Brócolis - R$ 7,80
- Couve-flor - R$ 8,20
- Beterraba - R$ 4,50
- Mandioca - R$ 3,50

---

## Views

### 1. `active_products`

Retorna todos os produtos ativos ordenados por nome.

```sql
CREATE OR REPLACE VIEW active_products AS
SELECT id, name, category, price, image_url, description, stock, created_at, updated_at
FROM products
WHERE is_active = true
ORDER BY name;
```

**Exemplo de uso:**

```sql
SELECT * FROM active_products;
```

---

### 2. `products_by_category`

Retorna estatísticas agregadas por categoria.

```sql
CREATE OR REPLACE VIEW products_by_category AS
SELECT
  category,
  COUNT(*) as total_products,
  AVG(price) as avg_price,
  SUM(stock) as total_stock
FROM products
WHERE is_active = true
GROUP BY category
ORDER BY category;
```

**Exemplo de uso:**

```sql
SELECT * FROM products_by_category;

-- Resultado:
-- category | total_products | avg_price | total_stock
-- fruta    | 10             | 7.31      | 985
-- verdura  | 10             | 3.18      | 1230
-- legume   | 15             | 7.38      | 1880
```

---

## Como Usar

### 1. Inicialização com Docker

O script é executado automaticamente quando o container PostgreSQL é criado:

```bash
docker compose -f docker-compose-local.yml up
```

O Docker montará o volume:

```yaml
volumes:
  - ./backend/db/init.sql:/docker-entrypoint-initdb.d/init.sql
```

---

### 2. Execução Manual

Se preferir executar o script manualmente:

```bash
# Conectar ao PostgreSQL
psql -h localhost -U postgres -d hortti_inventory

# Executar o script
\i backend/db/init.sql
```

---

### 3. Conexão via Aplicação

**Variáveis de Ambiente (.env):**

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=hortti_inventory
```

**TypeORM Config (NestJS):**

```typescript
TypeOrmModule.forRoot({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: 5432,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: [User, Product],
  synchronize: false, // IMPORTANTE: usar migrations em produção
})
```

---

### 4. Queries Úteis

**Verificar se o banco foi criado:**

```sql
-- Contar tabelas
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'public';

-- Listar tabelas
\dt

-- Ver total de produtos
SELECT COUNT(*) FROM products;

-- Ver total de usuários
SELECT COUNT(*) FROM users;
```

**Busca e Ordenação (conforme requisitos):**

```sql
-- Buscar por nome (case-insensitive)
SELECT * FROM products
WHERE name ILIKE '%banana%';

-- Ordenar por preço (crescente)
SELECT * FROM products
ORDER BY price ASC;

-- Ordenar por nome (alfabético)
SELECT * FROM products
ORDER BY name ASC;

-- Filtrar por categoria + ordenar
SELECT * FROM products
WHERE category = 'fruta'
ORDER BY price DESC;
```

---

## Triggers Automáticos

### `update_updated_at_column()`

Atualiza automaticamente o campo `updated_at` sempre que um registro é modificado.

```sql
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

**Exemplo:**

```sql
-- Atualizar produto
UPDATE products SET price = 4.50 WHERE id = 1;

-- O campo updated_at será atualizado automaticamente!
SELECT name, updated_at FROM products WHERE id = 1;
```

---

## Backup e Restore

### Backup do Banco

```bash
# Dump completo
pg_dump -h localhost -U postgres hortti_inventory > backup.sql

# Apenas dados (sem schema)
pg_dump -h localhost -U postgres --data-only hortti_inventory > data.sql

# Apenas schema (sem dados)
pg_dump -h localhost -U postgres --schema-only hortti_inventory > schema.sql
```

### Restore

```bash
# Restaurar backup completo
psql -h localhost -U postgres hortti_inventory < backup.sql
```

---

## Próximos Passos

- [ ] Adicionar tabela de `images` para múltiplas imagens por produto
- [ ] Implementar soft delete (não deletar, apenas marcar como inativo)
- [ ] Adicionar auditoria (log de mudanças)
- [ ] Criar índices de texto completo (Full-Text Search)
- [ ] Implementar migrations com TypeORM
- [ ] Adicionar validações de estoque mínimo

---

**Versão:** 1.0.0
**Última atualização:** 2025-10-21
**Autor:** Hortti Team
