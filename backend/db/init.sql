-- Hortti DB init
CREATE TABLE IF NOT EXISTS product (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC(10,2) DEFAULT 0,
  stock INTEGER DEFAULT 0,
  volume INTEGER,
  weight NUMERIC(10,2)
);

INSERT INTO product (name, category, price, stock) VALUES
('Tomate', 'Hortaliça', 5.50, 100),
('Alface', 'Hortaliça', 2.30, 200),
('Banana', 'Fruta', 3.20, 150);
