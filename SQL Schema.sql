--Guest
CREATE TABLE guests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    nic VARCHAR(12) NOT NULL UNIQUE;
    address VARCHAR(255),
    district VARCHAR(50),
    contact_number VARCHAR(15)
);

CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    guest_id INT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(10) DEFAULT 'guest',

    CONSTRAINT FK_users_guests FOREIGN KEY (guest_id)
    REFERENCES guests(id),

    CONSTRAINT chk_role CHECK (role IN ('admin', 'guest'))
);

--Rooms Type
CREATE TABLE room_types (
    id INT IDENTITY PRIMARY KEY,
    type_name VARCHAR(50),
    rate_per_night DECIMAL(10,2),
    description VARCHAR(255)
);


--Rooms
CREATE TABLE rooms (
    id INT IDENTITY PRIMARY KEY,
    room_number VARCHAR(10),
    type_id INT,

    FOREIGN KEY (type_id) REFERENCES room_types(id)
);

--Reservations
CREATE TABLE reservations (
    reservation_number INT IDENTITY(1,1) PRIMARY KEY,
    guest_id INT,
    room_id INT,
    checkin DATE,
    checkout DATE,
    rooms_booked INT,
    nights INT,
    total_amount DECIMAL(10,2),

    CONSTRAINT FK_res_guest FOREIGN KEY (guest_id)
    REFERENCES guests(id),

    CONSTRAINT FK_res_room FOREIGN KEY (room_id)
    REFERENCES rooms(id)
);


--Bills
CREATE TABLE bills (
    id INT IDENTITY(1,1) PRIMARY KEY,
    reservation_id INT,
    guest_id INT,
    amount DECIMAL(10,2),

    CONSTRAINT FK_bill_res FOREIGN KEY (reservation_id)
    REFERENCES reservations(reservation_number),

    CONSTRAINT FK_bill_guest FOREIGN KEY (guest_id)
    REFERENCES guests(id)
);