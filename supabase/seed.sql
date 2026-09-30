-- supabase/seed.sql

-- Seed Appliance Categories
INSERT INTO appliance_categories (name, icon, description) VALUES
('Refrigerator', 'fa-snowflake', 'All types of refrigerators'),
('Washing Machine', 'fa-soap', 'Top load, front load, and semi-automatic'),
('Air Conditioner', 'fa-wind', 'Window and Split ACs'),
('Television', 'fa-tv', 'LED, LCD, OLED, and Smart TVs'),
('Microwave Oven', 'fa-fire-burner', 'Microwave and Convection Ovens'),
('Water Purifier', 'fa-faucet-drip', 'RO, UV, and UF purifiers'),
('Geyser', 'fa-hot-tub-person', 'Electric and Gas Water Heaters'),
('Mixer/Grinder', 'fa-blender', 'Mixer, Grinder, and Juicers'),
('Air Cooler', 'fa-fan', 'Desert and Personal Coolers'),
('Dishwasher', 'fa-sink', 'Automatic dishwashers'),
('Inverter/UPS', 'fa-plug', 'Home inverters and UPS'),
('Laptop/Desktop', 'fa-laptop', 'Computer repair and maintenance'),
('Other', 'fa-screwdriver-wrench', 'Other electronic appliances');

-- Seed Appliances
INSERT INTO appliances (category_id, name, description) VALUES
(1, 'Single Door Refrigerator', 'Standard single door fridge'),
(1, 'Double Door Refrigerator', 'Frost-free double door fridge'),
(2, 'Top Load Washing Machine', 'Fully automatic top load'),
(2, 'Front Load Washing Machine', 'Fully automatic front load'),
(3, 'Split AC', 'Wall mounted split air conditioner'),
(3, 'Window AC', 'Window mounted air conditioner'),
(4, 'Smart LED TV', 'Smart television'),
(5, 'Convection Microwave', 'Microwave with convection heating');

-- Seed initial admin user profile (Note: the actual auth user must be created via Supabase Auth first, then its ID updated here)
-- INSERT INTO profiles (id, full_name, email, role, status) VALUES ('<REPLACE_WITH_AUTH_UUID>', 'Super Admin', 'admin@electronicservices.com', 'admin', 'approved');
