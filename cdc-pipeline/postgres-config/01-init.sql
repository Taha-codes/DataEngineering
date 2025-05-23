-- Create an e-commerce database schema
CREATE SCHEMA ecommerce;

-- Create tables
CREATE TABLE ecommerce.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    category VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce.customers(customer_id),
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    shipping_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES ecommerce.orders(order_id),
    product_id INTEGER REFERENCES ecommerce.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create function to update timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_customers_timestamp
BEFORE UPDATE ON ecommerce.customers
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_products_timestamp
BEFORE UPDATE ON ecommerce.products
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_orders_timestamp
BEFORE UPDATE ON ecommerce.orders
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Insert synthetic data: Customers
INSERT INTO ecommerce.customers (first_name, last_name, email, phone)
VALUES
    ('John', 'Doe', 'john.doe@example.com', '555-123-4567'),
    ('Jane', 'Smith', 'jane.smith@example.com', '555-234-5678'),
    ('Robert', 'Johnson', 'robert.johnson@example.com', '555-345-6789'),
    ('Sarah', 'Williams', 'sarah.williams@example.com', '555-456-7890'),
    ('Michael', 'Brown', 'michael.brown@example.com', '555-567-8901');

-- Insert synthetic data: Products
INSERT INTO ecommerce.products (product_name, description, price, stock_quantity, category)
VALUES
    ('Smartphone X', 'Latest smartphone with advanced features', 899.99, 50, 'Electronics'),
    ('Laptop Pro', 'High-performance laptop for professionals', 1299.99, 25, 'Electronics'),
    ('Wireless Headphones', 'Noise-cancelling wireless headphones', 199.99, 100, 'Audio'),
    ('Coffee Maker', 'Automatic coffee maker with timer', 79.99, 30, 'Kitchen Appliances'),
    ('Running Shoes', 'Lightweight running shoes for athletes', 129.99, 45, 'Footwear');

-- Insert synthetic data: Orders and Order Items
INSERT INTO ecommerce.orders (customer_id, total_amount, status, shipping_address)
VALUES
    (1, 899.99, 'completed', '123 Main St, Anytown, AN 12345'),
    (2, 1499.98, 'processing', '456 Oak Ave, Somewhere, SW 67890'),
    (3, 79.99, 'completed', '789 Pine Rd, Nowhere, NW 10111');

-- Add order items
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 899.99),
    (2, 2, 1, 1299.99),
    (2, 3, 1, 199.99),
    (3, 4, 1, 79.99);