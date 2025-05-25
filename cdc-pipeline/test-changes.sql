-- Insert a new customer
INSERT INTO ecommerce.customers (first_name, last_name, email, phone)
VALUES ('Emma', 'Davis', 'emma.davis@example.com', '555-987-6543');

-- Update a product
UPDATE ecommerce.products 
SET price = 849.99, stock_quantity = 45, updated_at = CURRENT_TIMESTAMP
WHERE product_id = 1;

-- Create a new order
INSERT INTO ecommerce.orders (customer_id, total_amount, status, shipping_address)
VALUES (4, 199.99, 'pending', '321 Elm St, Somewhere, SW 45678');

-- Add order items to the new order
INSERT INTO ecommerce.order_items (order_id, product_id, quantity, unit_price)
VALUES (4, 3, 1, 199.99);

-- Update order status
UPDATE ecommerce.orders
SET status = 'shipped'
WHERE order_id = 2;

-- Delete a test record (to demonstrate delete operations)
INSERT INTO ecommerce.customers (first_name, last_name, email, phone)
VALUES ('Test', 'User', 'test.delete@example.com', '555-000-0000');

DELETE FROM ecommerce.customers 
WHERE email = 'test.delete@example.com';