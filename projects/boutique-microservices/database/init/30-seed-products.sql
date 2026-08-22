-- ============================================================
-- SEED: 5 Additional Luxury Products
-- Runs automatically on first DB initialization (after 20-init-schema.sql).
-- Total: 10 products, each with a unique dedicated image (no sharing).
-- Uses ON CONFLICT (slug) DO NOTHING — safe to re-run.
-- ============================================================
\c products_db

-- Image mapping (1 image = 1 product):
--   sunglasses.jpg        → Gucci Sunglasses       (SUN-001)
--   cartier-bracelet.jpg  → Cartier Love Bracelet  (JEWEL-001)
--   trench-coat.jpg       → Burberry Trench Coat   (COAT-002)
--   leather-wallet.jpg    → YSL Leather Wallet     (WALLET-001)
--   ladies-watch.jpg      → Ladies Formal Watch    (WATCH-002)

INSERT INTO products (id, name, slug, description, short_description, sku, brand, category_id, price, compare_price, inventory_quantity, is_featured) VALUES
(gen_random_uuid(), 'Gucci Sunglasses',      'gucci-sunglasses',    'Classic oversized luxury sunglasses with UV400 protection',                       'Luxury oversized sunglasses',   'SUN-001',    'Gucci',              '10000000-0000-0000-0000-000000000002',  450.00,  550.00, 30, true),
(gen_random_uuid(), 'Cartier Love Bracelet', 'cartier-love',        '18K Yellow Gold iconic Love bracelet with signature screw motif',                  '18K Gold Love bracelet',        'JEWEL-001',  'Cartier',            '10000000-0000-0000-0000-000000000004', 7350.00, 7350.00,  5, true),
(gen_random_uuid(), 'Burberry Trench Coat',  'burberry-trench',     'Classic double-breasted cotton gabardine trench coat with signature check lining', 'Iconic gabardine trench coat',  'COAT-002',   'Burberry',           '10000000-0000-0000-0000-000000000001', 2490.00, 2490.00, 15, true),
(gen_random_uuid(), 'YSL Leather Wallet',    'ysl-wallet',          'Black quilted leather wallet with gold-tone YSL monogram clasp',                   'Quilted leather wallet',        'WALLET-001', 'Yves Saint Laurent', '10000000-0000-0000-0000-000000000002',  650.00,  650.00, 20, true),
(gen_random_uuid(), 'Ladies Formal Watch',   'ladies-formal-watch', 'Swiss-made rose gold watch with mother-of-pearl dial and diamond hour markers',    'Rose gold diamond watch',       'WATCH-002',  'LUXE BOUTIQUE',      '10000000-0000-0000-0000-000000000002', 3200.00, 3800.00,  8, true)
ON CONFLICT (slug) DO NOTHING;

-- Product images — 1 unique image per product
INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order)
SELECT p.id, '/product-images/sunglasses.jpg', 'Gucci Sunglasses - Main image', true, 1
FROM products p WHERE p.sku = 'SUN-001'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = true);

INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order)
SELECT p.id, '/product-images/cartier-bracelet.jpg', 'Cartier Love Bracelet - Main image', true, 1
FROM products p WHERE p.sku = 'JEWEL-001'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = true);

INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order)
SELECT p.id, '/product-images/trench-coat.jpg', 'Burberry Trench Coat - Main image', true, 1
FROM products p WHERE p.sku = 'COAT-002'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = true);

INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order)
SELECT p.id, '/product-images/leather-wallet.jpg', 'YSL Leather Wallet - Main image', true, 1
FROM products p WHERE p.sku = 'WALLET-001'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = true);

INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order)
SELECT p.id, '/product-images/ladies-watch.jpg', 'Ladies Formal Watch - Main image', true, 1
FROM products p WHERE p.sku = 'WATCH-002'
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = true);
