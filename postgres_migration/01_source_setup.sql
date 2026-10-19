DROP SCHEMA IF EXISTS shop CASCADE;
CREATE SCHEMA shop;
SET search_path TO shop;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city          TEXT
);
CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category     TEXT,
    unit_price   NUMERIC(10,2) CHECK (unit_price > 0)
);
CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id  INT REFERENCES products(product_id),
    quantity    INT CHECK (quantity > 0),
    order_date  DATE,
    status      TEXT DEFAULT 'NEW',
    order_total NUMERIC(12,2)
);
CREATE TABLE customer_summary (
    customer_id  INT PRIMARY KEY,
    total_orders INT,
    total_spent  NUMERIC(12,2)
);

INSERT INTO customers (customer_name, city) VALUES
 ('Asha','Chennai'),('Ravi','Mumbai'),('Meena','Pune'),('Karan','Hyderabad');
INSERT INTO products (product_name, category, unit_price) VALUES
 ('Laptop','Electronics',900.00),('Headphones','Electronics',60.00),
 ('Desk','Furniture',150.00),('Novel','Books',12.50);
INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
 (1,1,1,'2026-09-01'),(2,2,3,'2026-09-02'),(3,4,5,'2026-09-03'),
 (1,3,2,'2026-09-05'),(4,1,2,'2026-09-07'),(2,4,4,'2026-09-08'),
 (3,2,1,'2026-09-10'),(4,3,1,'2026-09-12'),(1,2,3,'2026-09-15'),
 (2,1,1,'2026-09-18'),(3,3,2,'2026-09-20'),(4,4,6,'2026-09-22');

-- Procedure 1: row by row, compute each order's total (10% discount when quantity >= 3)
CREATE OR REPLACE PROCEDURE calculate_order_totals() LANGUAGE plpgsql SET search_path = shop AS $$
DECLARE r RECORD; price NUMERIC;
BEGIN
  FOR r IN SELECT order_id, product_id, quantity FROM orders LOOP
    SELECT unit_price INTO price FROM products WHERE product_id = r.product_id;
    UPDATE orders
       SET order_total = CASE WHEN r.quantity >= 3
                              THEN price * r.quantity * 0.90
                              ELSE price * r.quantity END
     WHERE order_id = r.order_id;
  END LOOP;
END $$;

-- Procedure 2: row by row, rebuild each customer's order count and total spent
CREATE OR REPLACE PROCEDURE refresh_customer_summary() LANGUAGE plpgsql SET search_path = shop AS $$
DECLARE c RECORD;
BEGIN
  DELETE FROM customer_summary;
  FOR c IN SELECT customer_id FROM customers LOOP
    INSERT INTO customer_summary
    SELECT c.customer_id, COUNT(*), COALESCE(SUM(order_total),0)
      FROM orders WHERE customer_id = c.customer_id;
  END LOOP;
END $$;