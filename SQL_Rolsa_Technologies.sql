
CREATE DATABASE db_Relsa_Technologies;


CREATE TABLE tbl_Customers (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    UserEmail VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20) NULL
);


INSERT INTO tbl_Customers (FirstName, LastName, UserEmail, PhoneNumber)
VALUES ('John', 'Doe', 'johndoe@example.com', '123-456-7890');


-- Create the EV Stations table
CREATE TABLE EV_Stations (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    StationName VARCHAR(255) NOT NULL,
    StationLatitude DECIMAL(10, 6) NOT NULL,
    StationLongitude DECIMAL(10, 6) NOT NULL,
    StationAvailability ENUM('Spaces', 'No Spaces') NOT NULL,
    StationAppPayment BOOLEAN NOT NULL
);

-- Insert sample EV charging stations in Warrington
INSERT INTO EV_Stations (StationName, StationLatitude, StationLongitude, StationAvailability, StationAppPayment) VALUES
('Warrington Central Station', 53.390045, -2.596950, 'Spaces', 1),
('Golden Square Shopping Centre', 53.388300, -2.596200, 'No Spaces', 1),
('Stockton Heath Car Park', 53.374600, -2.580000, 'Spaces', 0),
('Birchwood Shopping Centre', 53.414600, -2.523500, 'Spaces', 1),
('Orford Jubilee Hub', 53.404500, -2.590900, 'No Spaces', 0);

-- Verify data
SELECT * FROM EV_Stations;

DELIMITER //
CREATE PROCEDURE GetNearbyStations(
    IN userLat DECIMAL(10,6),
    IN userLng DECIMAL(10,6),
    IN rangeKm DECIMAL(10,6)
)
BEGIN
    DECLARE latDiff DECIMAL(10,6);
    DECLARE lngDiff DECIMAL(10,6);
    
    SET latDiff = rangeKm / 111.32; -- Rough conversion for latitude degrees
    SET lngDiff = rangeKm / (111.32 * COS(RADIANS(userLat))); -- Adjust for longitude
    
    SELECT *, 
           (6371 * ACOS(
               COS(RADIANS(userLat)) * COS(RADIANS(StationLatitude)) * 
               COS(RADIANS(StationLongitude) - RADIANS(userLng)) + 
               SIN(RADIANS(userLat)) * SIN(RADIANS(StationLatitude))
           )) AS distance
    FROM EV_Stations
    WHERE StationLatitude BETWEEN (userLat - latDiff) AND (userLat + latDiff)
    AND StationLongitude BETWEEN (userLng - lngDiff) AND (userLng + lngDiff)
    HAVING distance <= rangeKm
    ORDER BY distance ASC;
END //
DELIMITER ;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
FLUSH PRIVILEGES;
