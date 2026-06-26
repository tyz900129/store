-- =====================================================
-- PawPatrol Store · 初始数据
-- =====================================================
USE `pawpatrol`;

INSERT INTO categories (id, name, icon, sort) VALUES
  ('bed',     'Beds & Caves',    'bed',     1),
  ('toy',     'Toys',            'toy',     2),
  ('apparel', 'Apparel',         'shirt',   3),
  ('bowl',    'Bowls & Diners',  'bowl',    4),
  ('travel',  'Travel & Walk',   'compass', 5),
  ('smart',   'Smart Gear',      'cpu',     6);

INSERT INTO products
  (title, slug, description, price, original_price, currency, images_json, category_id, pet, stock, rating)
VALUES
  ('Cloud Nine Cat Cave','cloud-nine-cat-cave',
   'Hand-felted from 100% New Zealand wool, our Cloud Nine cave gives your cat a snug, temperature-stable retreat. The curved silhouette muffles sound and the natural fibers are hypoallergenic.',
   49.00, 65.00, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimalist%20wool%20felt%20cat%20cave%20in%20warm%20terracotta%20on%20wooden%20floor%2C%20studio%20lighting%2C%20e-commerce%20photo&image_size=square_hd"]',
   'bed','cat',23,4.90),

  ('Bark & Breeze Leash','bark-breeze-leash',
   'Vegetable-tanned leather, hand-stitched with marine-grade brass. Softens with use, develops a patina, and lasts years of daily walks.',
   36.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=premium%20tan%20leather%20dog%20leash%20with%20brass%20clip%20on%20marble%20surface%2C%20product%20photo%2C%20warm%20light&image_size=square_hd"]',
   'travel','dog',50,4.80),

  ('Pebble Ceramic Bowl','pebble-ceramic-bowl',
   'Dishwasher-safe stoneware with a weighted base to prevent sliding. The shallow, wide shape is ergonomically designed to be whisker-friendly.',
   28.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimalist%20matte%20ceramic%20pet%20bowl%20in%20sage%20green%20on%20linen%2C%20product%20photo%2C%20natural%20light&image_size=square_hd"]',
   'bowl','cat',80,4.70),

  ('Wiggle Wand Refill Set','wiggle-wand-refill',
   'Six natural feather refills made from responsibly sourced materials. Connects to any standard wand handle (sold separately).',
   18.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=colorful%20eco%20feather%20cat%20toy%20refills%20on%20kraft%20paper%2C%20product%20flat%20lay%2C%20bright%20cheerful&image_size=square_hd"]',
   'toy','cat',120,4.90),

  ('Trailblazer Carrier','trailblazer-carrier',
   'Roomy, breathable, and stylish. The Trailblazer fits cats up to 6 kg and folds flat for easy storage.',
   89.00, 110.00, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20beige%20canvas%20pet%20carrier%20backpack%20on%20white%20background%2C%20product%20photo%2C%20minimalist&image_size=square_hd"]',
   'travel','cat',30,4.60),

  ('Hearth Wool Throw','hearth-wool-throw',
   'A throw that doubles as a dog bed liner. Naturally odor-resistant and warm.',
   64.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cozy%20merino%20wool%20throw%20blanket%20folded%20on%20wooden%20chair%2C%20warm%20interior%2C%20lifestyle&image_size=square_hd"]',
   'bed','dog',25,4.80),

  ('SmartSip Fountain','smartsip-fountain',
   'Circulates and filters 2L of water with ultra-quiet pump. Encourages cats to drink more, supporting kidney health.',
   79.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20white%20pet%20water%20fountain%20with%20blue%20light%2C%20product%20photo%2C%20dark%20background&image_size=square_hd"]',
   'smart','cat',40,4.50),

  ('Pawsh Puffer Jacket','pawsh-puffer-jacket',
   'Lightweight, water-resistant, and fully insulated. The elastic hem keeps warmth in without restricting movement.',
   58.00, NULL, 'USD',
   '["https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=stylish%20orange%20puffer%20dog%20jacket%20on%20small%20dog%2C%20studio%20photo%2C%20product&image_size=square_hd"]',
   'apparel','dog',35,4.70);

INSERT INTO reviews (product_id, author, rating, content, created_at) VALUES
  (1, 'Mei L.',     5, 'My cat refuses to leave this thing. Best purchase this year.', '2026-05-12'),
  (1, 'Jordan K.',  5, 'Beautiful craftsmanship, smells like real wool (in a good way).', '2026-04-28'),
  (2, 'Sam P.',     4, 'Leather is buttery soft. The brass clip is solid.', '2026-06-01'),
  (2, 'Anya R.',    5, 'Develops a gorgeous patina after a few weeks.', '2026-05-20');
