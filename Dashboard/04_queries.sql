USE food_rescue_intelligence;
SELECT * FROM Donor;
SELECT * FROM NGO;
SELECT * FROM Food_Item;
SELECT * FROM Driver;
SELECT * FROM Donation;
SELECT * FROM Donation WHERE status = 'Completed';
SELECT * FROM Donation WHERE status = 'Pending';
SELECT * FROM Donor WHERE donor_type = 'Restaurant';
SELECT * FROM NGO WHERE city = 'Bengaluru';
SELECT * FROM Donation ORDER BY donation_date DESC;
SELECT
    d.donation_id,
    dn.donor_name,
    d.donation_date,
    d.status
FROM Donation d
INNER JOIN Donor dn
ON d.donor_id = dn.donor_id;
SELECT
    di.donation_item_id,
    d.donation_id,
    f.food_name,
    di.quantity,
    f.unit
FROM Donation_Item di
INNER JOIN Donation d
ON di.donation_id = d.donation_id
INNER JOIN Food_Item f
ON di.food_item_id = f.food_item_id;
SELECT
    n.ngo_name,
    f.food_name,
    nr.required_quantity,
    nr.remaining_quantity
FROM NGO_Requirement nr
INNER JOIN NGO n
ON nr.ngo_id = n.ngo_id
INNER JOIN Food_Item f
ON nr.food_item_id = f.food_item_id;
SELECT
    n.ngo_name,
    f.food_name,
    da.allocated_quantity,
    da.allocation_date
FROM Donation_Allocation da
INNER JOIN Donation_Item di
ON da.donation_item_id = di.donation_item_id
INNER JOIN Food_Item f
ON di.food_item_id = f.food_item_id
INNER JOIN NGO n
ON da.ngo_id = n.ngo_id;
SELECT
    de.delivery_id,
    dr.driver_name,
    de.delivery_date,
    de.delivery_status
FROM Delivery de
INNER JOIN Driver dr
ON de.driver_id = dr.driver_id;
SELECT
    dd.delivery_id,
    dd.donation_id,
    de.delivery_date,
    de.delivery_status
FROM Delivery_Donation dd
INNER JOIN Delivery de
ON dd.delivery_id = de.delivery_id
ORDER BY dd.delivery_id;
SELECT COUNT(*) AS total_donors
FROM Donor;
SELECT COUNT(*) AS total_donations
FROM Donation;
SELECT
    dn.donor_name,
    COUNT(d.donation_id) AS total_donations
FROM Donor dn
INNER JOIN Donation d
ON dn.donor_id = d.donor_id
GROUP BY dn.donor_name
ORDER BY total_donations DESC;
SELECT
    dr.driver_name,
    COUNT(de.delivery_id) AS total_deliveries
FROM Driver dr
INNER JOIN Delivery de
ON dr.driver_id = de.driver_id
GROUP BY dr.driver_name
ORDER BY total_deliveries DESC;
SELECT
    n.ngo_name,
    SUM(da.allocated_quantity) AS total_allocated
FROM NGO n
INNER JOIN Donation_Allocation da
ON n.ngo_id = da.ngo_id
GROUP BY n.ngo_name
ORDER BY total_allocated DESC;
SELECT
    AVG(quantity) AS average_quantity
FROM Donation_Item;
SELECT
    f.food_name,
    COUNT(*) AS donation_count
FROM Food_Item f
INNER JOIN Donation_Item di
ON f.food_item_id = di.food_item_id
GROUP BY f.food_name
HAVING COUNT(*) > 1
ORDER BY donation_count DESC;
SELECT donor_name
FROM Donor
WHERE donor_id IN (
    SELECT donor_id
    FROM Donation
    GROUP BY donor_id
    HAVING COUNT(*) = (
        SELECT MAX(total_donations)
        FROM (
            SELECT COUNT(*) AS total_donations
            FROM Donation
            GROUP BY donor_id
        ) AS donation_counts
    )
);
SELECT food_name
FROM Food_Item
WHERE food_item_id IN (
    SELECT food_item_id
    FROM Donation_Item
    GROUP BY food_item_id
    HAVING SUM(quantity) = (
        SELECT MAX(total_quantity)
        FROM (
            SELECT SUM(quantity) AS total_quantity
            FROM Donation_Item
            GROUP BY food_item_id
        ) AS food_totals
    )
);
SELECT
    ngo_id,
    food_item_id,
    remaining_quantity
FROM NGO_Requirement
WHERE remaining_quantity >
(
    SELECT AVG(remaining_quantity)
    FROM NGO_Requirement
);
SELECT
    driver_name
FROM Driver
WHERE driver_id IN
(
    SELECT driver_id
    FROM Delivery
    GROUP BY driver_id
    HAVING COUNT(*) >
    (
        SELECT AVG(driver_total)
        FROM
        (
            SELECT COUNT(*) AS driver_total
            FROM Delivery
            GROUP BY driver_id
        ) AS avg_table
    )
);
CREATE VIEW vw_donation_details AS
SELECT
    d.donation_id,
    dn.donor_name,
    d.donation_date,
    d.status
FROM Donation d
INNER JOIN Donor dn
ON d.donor_id = dn.donor_id;
CREATE VIEW vw_ngo_requirements AS
SELECT
    n.ngo_name,
    f.food_name,
    nr.required_quantity,
    nr.remaining_quantity
FROM NGO_Requirement nr
INNER JOIN NGO n
ON nr.ngo_id = n.ngo_id
INNER JOIN Food_Item f
ON nr.food_item_id = f.food_item_id;

DELIMITER //
CREATE PROCEDURE GetAllDonors()
BEGIN
    SELECT *
    FROM Donor;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetDonationsByStatus(
    IN donationStatus VARCHAR(30)
)
BEGIN
    SELECT *
    FROM Donation
    WHERE status = donationStatus;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_prevent_negative_allocation
BEFORE INSERT ON Donation_Allocation
FOR EACH ROW
BEGIN
    IF NEW.allocated_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Allocated quantity must be greater than zero.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_prevent_negative_requirement
BEFORE UPDATE ON NGO_Requirement
FOR EACH ROW
BEGIN
    IF NEW.remaining_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Remaining quantity cannot be negative.';
    END IF;
END //
DELIMITER ;

CREATE INDEX idx_donation_donor
ON Donation(donor_id);

CREATE INDEX idx_donationitem_food
ON Donation_Item(food_item_id);
