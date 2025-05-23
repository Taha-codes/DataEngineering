-- Create a dedicated user for CDC operations
CREATE ROLE debezium WITH REPLICATION LOGIN PASSWORD 'dbz';

-- Grant necessary permissions to the CDC user
GRANT USAGE ON SCHEMA ecommerce TO debezium;
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce TO debezium;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA ecommerce TO debezium;

-- Create a publication for CDC
CREATE PUBLICATION dbz_publication FOR TABLE 
    ecommerce.customers, 
    ecommerce.products, 
    ecommerce.orders, 
    ecommerce.order_items;

-- Make sure future tables are automatically added to the publication
ALTER DEFAULT PRIVILEGES IN SCHEMA ecommerce GRANT SELECT ON TABLES TO debezium;