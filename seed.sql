INSERT INTO users (guest_id, email, password, role)
VALUES (
    1, 
    'admin@gmail.com', 
    'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7', 
    'admin'
);

-- Password: Admin123


--Room Types
INSERT INTO room_types (type_name, rate_per_night, description) VALUES
('Single Deluxe', 6500, 'Cozy single room with queen bed, air conditioning, Wi-Fi, and garden view. Ideal for solo travelers.'),
('Double Superior', 9500, 'Spacious room with king-size bed, balcony, ocean or pool view, and complimentary breakfast for two.'),
('Family Suite', 15000, 'Large suite with two bedrooms, living area, 4 beds, ideal for families. Includes mini-fridge and TV.'),
('Ocean View Suite', 18000, 'Premium suite with panoramic ocean view, king bed, luxury bathroom, and private balcony.');

--Single Deluxe (10 rooms)
INSERT INTO rooms (room_number, type_id) VALUES
('101',1),('102',1),('103',1),('104',1),('105',1),
('106',1),('107',1),('108',1),('109',1),('110',1);

--Double Superior (6 rooms)
INSERT INTO rooms (room_number, type_id) VALUES
('201',2),('202',2),('203',2),
('204',2),('205',2),('206',2);

--Family Suite (4 rooms)
INSERT INTO rooms (room_number, type_id) VALUES
('301',3),('302',3),('303',3),('304',3);

--Ocean View Suite (3 rooms)
INSERT INTO rooms (room_number, type_id) VALUES
('401',4),('402',4),('403',4);