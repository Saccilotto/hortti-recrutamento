-- ============================================
-- Hortti Inventory Database - Initialization
-- ============================================
-- Database: hortti_inventory
-- Description: Sistema de gestão de inventário do Cantinho Verde
-- Version: 1.0.0
-- ============================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABELA: users
-- Descrição: Usuários do sistema para autenticação JWT
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para otimização de busca
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- ============================================
-- TABELA: products
-- Descrição: Produtos do inventário (frutas, verduras, legumes)
-- ============================================
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL CHECK (category IN ('fruta', 'verdura', 'legume')),
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  image_url TEXT,
  description TEXT,
  stock INTEGER DEFAULT 0 CHECK (stock >= 0),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para otimização de busca e ordenação
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);

-- ============================================
-- TRIGGER: Atualizar updated_at automaticamente
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEEDS: Dados Iniciais
-- ============================================

INSERT INTO users (email, password, name, role) VALUES
('admin@cantinhoverde.com', '$2b$10$DCEZS5l6nXBZidwz3hV38ug7zgEqs4E6rOIL72r4Dh92SYotXYdHu', 'Administrador', 'admin'),
('user@cantinhoverde.com', '$2b$10$eFqhgmDk9cKjt2X1darQsu24Yq4IFm62w8Vd1seHICMzOscG/VB0C', 'Usuário Teste', 'user')
ON CONFLICT (email) DO NOTHING;

-- PRODUTOS INICIAIS - FRUTAS
INSERT INTO products (name, category, price, description, stock) VALUES
('Banana Prata', 'fruta', 3.99, 'Banana prata fresca, doce e nutritiva', 150),
('Maçã Fuji', 'fruta', 6.50, 'Maçã fuji crocante e suculenta', 120),
('Laranja Pera', 'fruta', 4.20, 'Laranja pera ideal para suco', 200),
('Mamão Papaya', 'fruta', 5.80, 'Mamão papaya maduro e docinho', 80),
('Manga Palmer', 'fruta', 7.90, 'Manga palmer grande e saborosa', 60),
('Abacaxi Pérola', 'fruta', 8.50, 'Abacaxi pérola super doce', 45),
('Melancia', 'fruta', 12.00, 'Melancia grande e refrescante', 30),
('Uva Itália', 'fruta', 9.90, 'Uva itália sem semente', 70),
('Morango', 'fruta', 11.50, 'Morango fresco higienizado', 50),
('Limão Taiti', 'fruta', 2.80, 'Limão taiti azedo e suculento', 180)
ON CONFLICT DO NOTHING;

-- PRODUTOS INICIAIS - VERDURAS
INSERT INTO products (name, category, price, description, stock) VALUES
('Alface Americana', 'verdura', 2.50, 'Alface americana crocante', 200),
('Alface Crespa', 'verdura', 2.30, 'Alface crespa verdinha', 180),
('Rúcula', 'verdura', 3.20, 'Rúcula fresca e levemente amarga', 100),
('Couve Manteiga', 'verdura', 2.80, 'Couve manteiga orgânica', 150),
('Acelga', 'verdura', 3.50, 'Acelga fresca e nutritiva', 90),
('Espinafre', 'verdura', 4.20, 'Espinafre baby higienizado', 110),
('Agrião', 'verdura', 3.80, 'Agrião fresco e picante', 85),
('Chicória', 'verdura', 2.90, 'Chicória lisa verdinha', 95),
('Almeirão', 'verdura', 2.70, 'Almeirão fresco', 100),
('Repolho Verde', 'verdura', 3.90, 'Repolho verde firme', 120)
ON CONFLICT DO NOTHING;

-- PRODUTOS INICIAIS - LEGUMES
INSERT INTO products (name, category, price, description, stock) VALUES
('Tomate Italiano', 'legume', 5.50, 'Tomate italiano maduro', 100),
('Tomate Cereja', 'legume', 8.90, 'Tomate cereja doce', 70),
('Batata Inglesa', 'legume', 3.80, 'Batata inglesa graúda', 250),
('Batata Doce', 'legume', 4.50, 'Batata doce roxa', 180),
('Cenoura', 'legume', 3.20, 'Cenoura fresca e crocante', 200),
('Cebola', 'legume', 4.90, 'Cebola branca média', 220),
('Alho', 'legume', 25.00, 'Alho nacional - 500g', 50),
('Pimentão Verde', 'legume', 6.80, 'Pimentão verde grande', 90),
('Pimentão Vermelho', 'legume', 7.50, 'Pimentão vermelho doce', 80),
('Abobrinha', 'legume', 4.20, 'Abobrinha italiana fresca', 110),
('Berinjela', 'legume', 5.90, 'Berinjela roxa grande', 75),
('Brócolis', 'legume', 7.80, 'Brócolis verde fresco', 65),
('Couve-flor', 'legume', 8.20, 'Couve-flor branquinha', 60),
('Beterraba', 'legume', 4.50, 'Beterraba roxa fresca', 130),
('Mandioca', 'legume', 3.50, 'Mandioca amarelinha', 140)
ON CONFLICT DO NOTHING;

-- ============================================
-- VIEWS: Para facilitar consultas
-- ============================================

-- View de produtos ativos
CREATE OR REPLACE VIEW active_products AS
SELECT
  id,
  name,
  category,
  price,
  image_url,
  description,
  stock,
  created_at,
  updated_at
FROM products
WHERE is_active = true
ORDER BY name;

-- View de produtos por categoria
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

-- ============================================
-- COMENTÁRIOS NAS TABELAS
-- ============================================
COMMENT ON TABLE users IS 'Usuários do sistema com autenticação JWT';
COMMENT ON TABLE products IS 'Produtos do inventário (frutas, verduras e legumes)';
COMMENT ON COLUMN products.category IS 'Categoria do produto: fruta, verdura ou legume';
COMMENT ON COLUMN products.price IS 'Preço em reais (BRL)';
COMMENT ON COLUMN products.image_url IS 'URL da imagem do produto (pode ser local ou externa)';

-- ============================================
-- FIM DO SCRIPT
-- ============================================
