# Hortti Inventory - Frontend

> Interface React/Next.js para gestão de inventário

## Tecnologias

- **Framework:** Next.js 14.0 (Pages Router)
- **Linguagem:** TypeScript 5.3
- **Estilização:** Tailwind CSS 3.4
- **HTTP Client:** Axios 1.6
- **State Management:** React Context API
- **Node:** 18.x

## Estrutura do Projeto

```text
frontend/
├── pages/
│   ├── _app.tsx            # Provider de autenticação
│   ├── index.tsx           # Redirect para /products
│   ├── login.tsx           # Página de login
│   └── products/
│       ├── index.tsx       # Listagem de produtos
│       ├── create.tsx      # Criar produto
│       └── [id]/
│           └── edit.tsx    # Editar produto
├── components/
│   ├── Layout.tsx          # Layout principal
│   ├── Navbar.tsx          # Barra de navegação
│   ├── Button.tsx          # Botão reutilizável
│   ├── Input.tsx           # Input reutilizável
│   ├── Select.tsx          # Select reutilizável
│   ├── Card.tsx            # Card reutilizável
│   ├── Loading.tsx         # Componente de carregamento
│   └── ProductForm.tsx     # Formulário de produto
├── contexts/
│   └── AuthContext.tsx     # Contexto de autenticação
├── services/
│   ├── auth.service.ts     # Serviço de autenticação
│   └── products.service.ts # Serviço de produtos
├── lib/
│   └── api.ts              # Configuração do Axios
└── styles/
    └── globals.css         # Estilos globais + Tailwind
```

## Funcionalidades

### Autenticação

- Login com JWT
- Proteção de rotas
- Logout
- Armazenamento de token no localStorage

### Gestão de Produtos

- Listagem com paginação
- Busca por nome (case-insensitive)
- Filtro por categoria
- Ordenação por nome/preço
- Criação de produtos (autenticado)
- Edição de produtos (autenticado)
- Upload/atualização de imagens (autenticado)
- Exclusão de produtos (autenticado)

## Instalação

```bash
cd frontend
npm install
```

## Executar

### Desenvolvimento

```bash
npm run dev
```

Acesse: [http://localhost:3000](http://localhost:3000)

### Produção

```bash
npm run build
npm start
```

## Páginas

### Públicas

**`/`** - Redirect para `/products`
**`/products`** - Listagem de produtos
**`/login`** - Login

### Protegidas (requer autenticação)

**`/products/create`** - Criar novo produto
**`/products/[id]/edit`** - Editar produto existente

## Componentes

### Layout & Navegação

**Layout** - Wrapper com Navbar
**Navbar** - Barra de navegação com links e botões contextuais

### Formulários

**Input** - Campo de texto com label e erro
**Select** - Campo de seleção com opções
**Button** - Botão com variantes (primary, secondary, danger)
**ProductForm** - Formulário completo de produto

### Utilidades

**Card** - Container com sombra
**Loading** - Spinner de carregamento

## Contexto de Autenticação

```typescript
const { user, token, loading, login, logout, isAuthenticated } = useAuth();
```

**Métodos:**

- `login(credentials)` - Faz login e armazena token
- `logout()` - Remove token e redireciona
- `isAuthenticated` - Booleano indicando se está autenticado

## Serviços

### Auth Service

```typescript
authService.login(credentials)
authService.register(userData)
authService.getProfile()
authService.verifyToken()
```

### Products Service

```typescript
productsService.getAll(params)
productsService.getById(id)
productsService.create(data)
productsService.update(id, data)
productsService.delete(id)
productsService.uploadImage(id, file)
```

## Variáveis de Ambiente

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api
```

## Tailwind CSS

Configurado com:

- Cores customizadas
- Classes utilitárias
- Responsividade mobile-first

Principais classes utilizadas:

- Layout: `container`, `mx-auto`, `px-4`
- Grid: `grid`, `grid-cols-*`, `gap-*`
- Cores: `bg-green-600`, `text-gray-700`
- Espaçamento: `p-*`, `m-*`, `space-*`
- Responsividade: `md:`, `lg:`, `xl:`

## Fluxo de Navegação

```text
/ (index)
  → Redirect para /products

/login
  → Formulário de login
  → Sucesso: /products

/products
  → Listagem pública
  → Botões de ação (se autenticado)

/products/create (protegido)
  → Formulário de criação
  → Sucesso: /products

/products/[id]/edit (protegido)
  → Formulário de edição
  → Upload de imagem
  → Sucesso: /products
```

## Credenciais de Teste

**Admin:**

```text
Email: admin@cantinhoverde.com
Senha: Admin@123
```

**User:**

```text
Email: user@cantinhoverde.com
Senha: User@123
```

## Problemas Comuns

### API não conecta

Verifique se:

1. Backend está rodando na porta 3001
2. Variável `NEXT_PUBLIC_API_URL` está correta
3. CORS está habilitado no backend

### Token expirado

O interceptor do Axios remove automaticamente o token e redireciona para `/login` quando recebe 401.

### Imagens não aparecem

Verifique se o backend está servindo arquivos estáticos em `/uploads`.

---

**Versão:** 1.0.0
**Última atualização:** 2025-10-21
