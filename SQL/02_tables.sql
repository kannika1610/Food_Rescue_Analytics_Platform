USE food_rescue_intelligence;
CREATE TABLE Donor (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(100) NOT NULL,
    donor_type VARCHAR(30) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE NGO (
    ngo_id INT AUTO_INCREMENT PRIMARY KEY,
    ngo_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Food_Item (
    food_item_id INT AUTO_INCREMENT PRIMARY KEY,
    food_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Driver (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Donation (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    donation_date DATETIME NOT NULL,
    pickup_address VARCHAR(255) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_donation_donor
        FOREIGN KEY (donor_id)
        REFERENCES Donor(donor_id)
);
CREATE TABLE Donation_Item (
    donation_item_id INT AUTO_INCREMENT PRIMARY KEY,
    donation_id INT NOT NULL,
    food_item_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_donationitem_donation
        FOREIGN KEY (donation_id)
        REFERENCES Donation(donation_id),

    CONSTRAINT fk_donationitem_fooditem
        FOREIGN KEY (food_item_id)
        REFERENCES Food_Item(food_item_id)
);
CREATE TABLE NGO_Requirement (
    requirement_id INT AUTO_INCREMENT PRIMARY KEY,
    ngo_id INT NOT NULL,
    food_item_id INT NOT NULL,
    required_quantity DECIMAL(10,2) NOT NULL,
    remaining_quantity DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_requirement_ngo
        FOREIGN KEY (ngo_id)
        REFERENCES NGO(ngo_id),

    CONSTRAINT fk_requirement_fooditem
        FOREIGN KEY (food_item_id)
        REFERENCES Food_Item(food_item_id)
);
CREATE TABLE Delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    delivery_date DATETIME NOT NULL,
    delivery_status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_delivery_driver
        FOREIGN KEY (driver_id)
        REFERENCES Driver(driver_id)
);
CREATE TABLE Delivery_Donation (
    delivery_id INT NOT NULL,
    donation_id INT NOT NULL,

    PRIMARY KEY (delivery_id, donation_id),

    CONSTRAINT fk_deliverydonation_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES Delivery(delivery_id),

    CONSTRAINT fk_deliverydonation_donation
        FOREIGN KEY (donation_id)
        REFERENCES Donation(donation_id)
);
CREATE TABLE Donation_Allocation (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    donation_item_id INT NOT NULL,
    ngo_id INT NOT NULL,
    allocated_quantity DECIMAL(10,2) NOT NULL,
    allocation_date DATETIME NOT NULL,

    CONSTRAINT fk_allocation_donationitem
        FOREIGN KEY (donation_item_id)
        REFERENCES Donation_Item(donation_item_id),

    CONSTRAINT fk_allocation_ngo
        FOREIGN KEY (ngo_id)
        REFERENCES NGO(ngo_id)
);