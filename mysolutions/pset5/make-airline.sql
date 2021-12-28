DROP TABLE ticket;
DROP TABLE international_info;
DROP TABLE traveller;
DROP TABLE purchase;
DROP TABLE payment_info;
DROP TABLE purchaser;
DROP TABLE phone;
DROP TABLE customer;
DROP TABLE flight;
DROP TABLE seat;
DROP TABLE aircraft;

-- Airplane Information
CREATE TABLE aircraft (
  -- The IATA aircraft type code, unique for every kind of aircraft.
  aircraft_type CHAR(3) PRIMARY KEY,  
  -- The manufacturer’s company (e.g. “Airbus” or “Boeing”)
  manufacturer VARCHAR(30) NOT NULL, 
  -- The aircraft’s model (e.g. “A380” or “747-400”)
  model VARCHAR(30) NOT NULL
);

-- information about the seats available on an aircraft 
CREATE TABLE seat (
  aircraft_type CHAR(3),
  -- A seat number such as “34A” or “15E”
  seat_no CHAR(3) NOT NULL,   
  -- A “seat class” such as 
  -- - “first class” ('F')
  -- - “business class” ('B')
  -- - “coach” ('C')
  class CHAR(1) NOT NULL, 
  -- A “seat type” specifying whether the seat is:
  --  - aisle ('A')
  --  - middle ('M')
  --  - window seat ('W')
  seat_type CHAR(1) NOT NULL, 
  -- A flag specifying whether the seat is in an exit row
  is_exit BOOLEAN NOT NULL,
  
  PRIMARY KEY (aircraft_type, seat_no),
  FOREIGN KEY (aircraft_type) REFERENCES aircraft(aircraft_type)
    ON DELETE CASCADE,
  
  CHECK (seat_type IN ('A', 'M', 'W'))
);

-- Flight Information
CREATE TABLE flight (
  -- flight number (a short string, e.g. “QF11” or “QF108”)
  flight_no VARCHAR(10), 
  -- flight date (e.g. “2007-05-21”)
  date DATE,   
  -- flight time (e.g. “14:10:00”)
  time TIME NOT NULL, 
  -- source airport, (IATA) airport code
  src CHAR(3) NOT NULL, 
  -- destination airport, (IATA) airport code
  dst CHAR(3) NOT NULL,
  -- A flag, meaning
  -- - FALSE: domestic (within the country)
  -- - TRUE: international (between two countries)
  -- The reason for this is that travelers must provide additional 
  -- information when on an international flight.
  is_inter BOOLEAN NOT NULL, 
  -- Kind of airplane that is used for the flight
  aircraft_type CHAR(3) NOT NULL,
  
  PRIMARY KEY (flight_no, date),
  FOREIGN KEY (aircraft_type) REFERENCES aircraft(aircraft_type)
);

-- Customer information
CREATE TABLE customer (
  -- surrogate key
  customer_id INTEGER AUTO_INCREMENT PRIMARY KEY,   
  first_name VARCHAR(50) NOT NULL, 
  last_name VARCHAR(50) NOT NULL, 
  email VARCHAR(50) NOT NULL,
  -- primary phone number, customer can have more in 'phone' table
  phone VARCHAR(30) NOT NULL
);

-- Additional customer phone numbers
CREATE TABLE phone (
  customer_id INTEGER, 
  phone_no VARCHAR(30),
  
  PRIMARY KEY (customer_id, phone_no),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON DELETE CASCADE
);

-- Purchaser information
CREATE TABLE purchaser (
  -- The purchaser id
  customer_id INTEGER PRIMARY KEY,  
  
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Optional payment information
CREATE TABLE payment_info (
  -- The purchaser
  customer_id INTEGER PRIMARY KEY, 
  -- 16-digit credit card number
  cc_no CHAR(16) NOT NULL, 
  -- credit card expiration date (MM/YY)
  cc_exp CHAR(5) NOT NULL, 
  -- 3-digit card verification code
  cc_cvc  CHAR(3) NOT NULL,
  
  FOREIGN KEY (customer_id) REFERENCES purchaser(customer_id)
    ON DELETE CASCADE,
  
  CONSTRAINT cc_no_fmt  CHECK  (cc_no REGEXP '^[0-9]{16}$'),
  CONSTRAINT cc_exp_fmt CHECK  (cc_exp REGEXP '^[0-9]{2}/[0-9]{2}$'),
  CONSTRAINT cc_no_cvc  CHECK  (cc_cvc REGEXP '^[0-9]{3}$')
);

-- A collection of one or more tickets bought by a particular 
-- purchaser in a single transaction
CREATE TABLE purchase (
  -- An integer ID that uniquely identifies the purchase
  purchase_id INTEGER AUTO_INCREMENT PRIMARY KEY,  
  -- The purchaser
  customer_id INTEGER NOT NULL, 
  -- A timestamp specifying when the purchase occurred
  timestamp TIMESTAMP NOT NULL, 
  -- A six-character “confirmation number” that the purchaser can use to 
  -- access the purchase. 
  confirmation_no CHAR(6) NOT NULL UNIQUE,
  
  FOREIGN KEY (customer_id) REFERENCES purchaser(customer_id),
  
  CONSTRAINT confirmation_no_fmt 
    CHECK (confirmation_no REGEXP '^([A-Z]|[0-9]){6}$')
);

-- Traveller information 
CREATE TABLE traveller (
  -- The traveller id
  customer_id INTEGER PRIMARY KEY,  
  -- frequent flyer number
  freq_flyer_no CHAR(7),
  
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id), 
  
  CONSTRAINT freq_flyer_no_fmt 
    CHECK (freq_flyer_no REGEXP '^([A-Z]|[0-9]){7}$')
);

-- Additional details travelers must provide for international flights.
CREATE TABLE international_info (  
  -- The traveller
  customer_id INTEGER PRIMARY KEY, 
  -- Passport number
  passport_no VARCHAR(40) NOT NULL,
  -- The country of citizenship for the passport
  country VARCHAR(40) NOT NULL, 
  -- The name of an emergency contact 
  emergency_contact VARCHAR(60) NOT NULL, 
  -- A single phone number for the emergency contact
  emergency_phone VARCHAR(30) NOT NULL, 
  
  FOREIGN KEY (customer_id) REFERENCES traveller(customer_id)
    ON DELETE CASCADE
);

-- Ticket for a flight
CREATE TABLE ticket(
  -- Ticket id
  ticket_id INTEGER AUTO_INCREMENT PRIMARY KEY, 
  -- Sale price of the ticket
  price NUMERIC(7,2) NOT NULL,
  -- flight number
  flight_no VARCHAR(10) NOT NULL, 
  -- flight date
  date DATE NOT NULL,
  -- aircraft, needed to identify the seat number
  aircraft_type CHAR(3) NOT NULL,
  -- seat number
  seat_no CHAR(3) NOT NULL,  
  -- The purchase this ticket belongs to
  purchase_id INTEGER NOT NULL, 
  -- The traveller
  customer_id INTEGER NOT NULL,
  
  FOREIGN KEY (flight_no, date) REFERENCES flight(flight_no, date),
  FOREIGN KEY (aircraft_type, seat_no) REFERENCES seat(aircraft_type, seat_no),
  FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id),
  FOREIGN KEY (customer_id) REFERENCES traveller(customer_id)
  
  -- CONSTRAINT seat_is_in_flight_aircraft CHECK (
  --  SELECT aircraft_type 
  --  FROM flight AS f
  --  WHERE f.flight_no = flight_no AND f.date = date
  -- )
);

