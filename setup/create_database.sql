CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    floor_id INT,
    name VARCHAR(255) NOT NULL,
    quantity INT,
    active CHAR,
    notes TEXT,
    description TEXT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    active CHAR,
    notes TEXT,
    description TEXT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS buildings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT,
    name VARCHAR(255) NOT NULL,
    active CHAR,
    notes TEXT,
    description TEXT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS floors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    building_id INT,
    name VARCHAR(255) NOT NULL,
    active CHAR,
    notes TEXT,
    description TEXT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    active CHAR,
    description TEXT,
    online_description TEXT,
    icon VARCHAR(255),
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS room_attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    attribute_id INT,
    active CHAR,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255),
    pw VARCHAR(255),
    active CHAR,
    admin CHAR,
    forename VARCHAR(255),
    surname VARCHAR(255),
    role VARCHAR(255),
    last_password_change DATE,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    last_active DATE,
    ip VARCHAR(100),
    cookie CHAR(128),
    csrf_token CHAR(128),
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS room_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    customer_id INT,
    confirmed CHAR,
    date_from DATE,
    date_to DATE,
    notes TEXT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS system_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    value VARCHAR(255),
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255),
    banned CHAR,
    forename VARCHAR(255),
    surname VARCHAR(255),
    postcode VARCHAR(255),
    phone VARCHAR(255),
    user_id INT,
    added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;