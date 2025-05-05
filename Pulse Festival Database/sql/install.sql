DROP TABLE IF EXISTS entity_image;
DROP TABLE IF EXISTS image;
DROP TABLE IF EXISTS resale_transactions;
DROP TABLE IF EXISTS seller;
DROP TABLE IF EXISTS buyer;
DROP TABLE IF EXISTS seller_queue;
DROP TABLE IF EXISTS buyer_queue;
DROP TABLE IF EXISTS rates;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS visitor_tickets;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS event_staff;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS performance_artistband;
DROP TABLE IF EXISTS performance;
DROP TABLE IF EXISTS event_venue;
DROP TABLE IF EXISTS venue;
DROP TABLE IF EXISTS festival_event;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS festival_location;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS festival;
DROP TABLE IF EXISTS artist_band_genre;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS memberof;
DROP TABLE IF EXISTS artistband;
DROP TABLE IF EXISTS visitor;

CREATE TABLE visitor (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL, 
    last_name VARCHAR(50) NOT NULL,
    age TINYINT UNSIGNED NOT NULL,
    email VARCHAR(254) NOT NULL CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}$'),
    phone CHAR(10) NOT NULL CHECK (phone REGEXP '[0-9]{10}'),
    PRIMARY KEY (id)   
);

CREATE TABLE artistband (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type VARCHAR(6) NOT NULL CHECK (type IN ('Artist', 'Band')),
    name VARCHAR(100) NOT NULL,
    alias VARCHAR(100) UNIQUE,
    birthdate_formation_date DATE NOT NULL,
    website VARCHAR(255) CHECK (website LIKE 'http%'),
    instagram VARCHAR(255) UNIQUE CHECK (instagram LIKE 'https://www.instagram.com/%'),
    PRIMARY KEY (id)
);

CREATE TABLE genre (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,
    parent_genre VARCHAR(50),
    PRIMARY KEY (id),
    UNIQUE (genre_name, parent_genre)
);

CREATE TABLE artist_band_genre (
    artist_band_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (artist_band_id, genre_id),
    FOREIGN KEY (artist_band_id) REFERENCES artistband(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE CASCADE
);

CREATE TABLE memberof (
    artist_id INT UNSIGNED NOT NULL,
    band_id INT UNSIGNED NOT NULL,
    join_date DATE NOT NULL,
    leave_date DATE,
    role VARCHAR(100) NOT NULL,
    PRIMARY KEY (artist_id, band_id),
    FOREIGN KEY (artist_id) REFERENCES artistband(id) ON DELETE CASCADE,
    FOREIGN KEY (band_id) REFERENCES artistband(id) ON DELETE CASCADE,
    CHECK (artist_id <> band_id),
    CHECK (leave_date IS NULL OR leave_date > join_date)
);

CREATE TABLE festival (
    year INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration INT GENERATED ALWAYS AS (DATEDIFF(end_date, start_date) + 1) STORED,
    PRIMARY KEY (year),
    CHECK (start_date <= end_date)
);

CREATE TABLE location (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(255) NOT NULL,
    geo_coordinates VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    continent VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE festival_location (
    festival_year INT NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (festival_year, location_id),
    FOREIGN KEY (festival_year) REFERENCES festival(year),
    FOREIGN KEY (location_id) REFERENCES location(id)
);

CREATE TABLE event (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    festival_year INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL CHECK (start_time BETWEEN '00:00:00' AND '23:59:59'),
    end_time TIME NOT NULL CHECK (end_time BETWEEN '00:00:00' AND '23:59:59'),
    duration TIME GENERATED ALWAYS AS (TIMEDIFF(end_time, start_time)) STORED,
    PRIMARY KEY (id),
    FOREIGN KEY (festival_year) REFERENCES festival(year),
    CHECK (start_time < end_time)
);

CREATE TABLE venue (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT UNSIGNED NOT NULL,
    technical_requirements TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE event_venue (
    event_id INT UNSIGNED NOT NULL,
    venue_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (event_id, venue_id),
    FOREIGN KEY (event_id) REFERENCES event(id),
    FOREIGN KEY (venue_id) REFERENCES venue(id)
);

CREATE TABLE performance (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id INT UNSIGNED NOT NULL,
    venue_id INT UNSIGNED NOT NULL,
    performance_type VARCHAR(50) NOT NULL CHECK (performance_type IN ('warm up', 'headline', 'Special guest', 'other')),
    start_time TIME NOT NULL CHECK (start_time BETWEEN '00:00:00' AND '23:59:59'),
    duration TIME NOT NULL CHECK (duration <= '03:00:00'),
    sequence_number INT UNSIGNED NOT NULL,
    break_duration TIME NOT NULL CHECK (break_duration BETWEEN '00:05:00' AND '00:30:00'),
    PRIMARY KEY (id),
    FOREIGN KEY (event_id, venue_id) REFERENCES event_venue(event_id, venue_id),
    UNIQUE (event_id, venue_id, sequence_number)
);

CREATE TABLE performance_artistband (
    performance_id INT UNSIGNED NOT NULL,
    artist_band_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (performance_id, artist_band_id),
    FOREIGN KEY (performance_id) REFERENCES performance(id),
    FOREIGN KEY (artist_band_id) REFERENCES artistband(id)
);

CREATE TABLE staff (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age TINYINT UNSIGNED NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('technical', 'security', 'support')),
    experience_level VARCHAR(20) NOT NULL CHECK (experience_level IN ('trainee', 'beginner', 'intermediate', 'experienced', 'expert')),
    PRIMARY KEY (id)
);

CREATE TABLE event_staff (
    event_id INT UNSIGNED NOT NULL,
    staff_id INT UNSIGNED NOT NULL,
    assignment_date DATE NOT NULL,
    shift_start DATETIME NOT NULL,
    shift_end DATETIME NOT NULL,
    PRIMARY KEY (event_id, staff_id, assignment_date),
    FOREIGN KEY (event_id) REFERENCES event(id),
    FOREIGN KEY (staff_id) REFERENCES staff(id),
    CHECK (shift_start < shift_end)
);

CREATE TABLE tickets (
    EAN13 CHAR(13) NOT NULL CHECK (EAN13 REGEXP '^[0-9]{13}$'),
    category VARCHAR(3) NOT NULL CHECK (category IN ('GA', 'VIP', 'BaS')),
    purchase_date DATE NOT NULL,
    price DECIMAL(6,2) UNSIGNED NOT NULL,
    payment_method CHAR(2) NOT NULL CHECK (payment_method IN ('CC', 'DC', 'BC', 'NC')),
    isActivated BOOLEAN NOT NULL DEFAULT 0,
    event_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (EAN13),
    FOREIGN KEY (event_id) REFERENCES event(id)
);

CREATE TABLE visitor_tickets (
    visitor_id INT UNSIGNED NOT NULL,
    ticket_id CHAR(13) NOT NULL,
    PRIMARY KEY (visitor_id, ticket_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(EAN13)
);

CREATE TABLE buyer_queue (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    event_id INT UNSIGNED NOT NULL,
    ticket_type VARCHAR(3) NOT NULL CHECK (ticket_type IN ('GA', 'VIP', 'BaS')),
    request_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'cancelled')),
    PRIMARY KEY (id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (event_id) REFERENCES event(id)
);

CREATE TABLE seller_queue (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    ticket_id CHAR(13) NOT NULL,
    list_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sold', 'cancelled')),
    PRIMARY KEY (id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(EAN13)
);

CREATE TABLE resale_transactions (
    buyer_queue_id INT UNSIGNED NOT NULL,
    seller_queue_id INT UNSIGNED NOT NULL,
    transaction_date DATETIME NOT NULL,
    PRIMARY KEY (buyer_queue_id, seller_queue_id),
    FOREIGN KEY (buyer_queue_id) REFERENCES buyer_queue(id),
    FOREIGN KEY (seller_queue_id) REFERENCES seller_queue(id)
);

CREATE TABLE evaluation (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    artist_performance TINYINT UNSIGNED NOT NULL CHECK (artist_performance BETWEEN 1 AND 5),
    sound_lighting TINYINT UNSIGNED NOT NULL CHECK (sound_lighting BETWEEN 1 AND 5),
    stage_presence TINYINT UNSIGNED NOT NULL CHECK (stage_presence BETWEEN 1 AND 5),
    organization TINYINT UNSIGNED NOT NULL CHECK (organization BETWEEN 1 AND 5),
    overall_impression TINYINT UNSIGNED NOT NULL CHECK (overall_impression BETWEEN 1 AND 5),
    PRIMARY KEY (id)
);

CREATE TABLE rates (
    visitor_id INT UNSIGNED NOT NULL,
    performance_id INT UNSIGNED NOT NULL,
    evaluation_id INT UNSIGNED NOT NULL,
    rating_date DATETIME NOT NULL,
    PRIMARY KEY (visitor_id, performance_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (performance_id) REFERENCES performance(id),
    FOREIGN KEY (evaluation_id) REFERENCES evaluation(id)
);

CREATE TABLE image (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    url VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('poster', 'artist', 'venue', 'performance', 'equipment')),
    PRIMARY KEY (id)
);

CREATE TABLE entity_image (
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('festival', 'artist', 'venue', 'performance', 'equipment')),
    entity_id INT UNSIGNED NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    upload_date DATE NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_type, entity_id, image_id),
    FOREIGN KEY (image_id) REFERENCES image(id)
);

DELIMITER //
CREATE TRIGGER check_visitor_has_activated_ticket BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    DECLARE ticket_count INT;
    
    SELECT COUNT(*) INTO ticket_count
    FROM tickets
    JOIN visitor_tickets ON tickets.EAN13 = visitor_tickets.ticket_id
    JOIN event ON tickets.event_id = event.id
    JOIN performance ON event.id = performance.event_id
    WHERE visitor_tickets.visitor_id = NEW.visitor_id
    AND performance.id = NEW.performance_id
    AND tickets.isActivated = 1;
    
    IF (ticket_count = 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Visitor must have an activated ticket to rate a performance';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_ticket_not_activated BEFORE INSERT ON seller_queue
FOR EACH ROW
BEGIN
    DECLARE is_activated BOOLEAN;
    
    SELECT tickets.isActivated INTO is_activated
    FROM tickets
    WHERE tickets.EAN13 = NEW.ticket_id;
    
    IF (is_activated = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot sell an activated ticket';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_venue_capacity BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    DECLARE venue_capacity INT;
    DECLARE sold_tickets INT;
    DECLARE vip_tickets INT;
    
    SELECT venue.max_capacity INTO venue_capacity
    FROM event
    JOIN event_venue ON event.id = event_venue.event_id
    JOIN venue ON event_venue.venue_id = venue.id
    WHERE event.id = NEW.event_id;
    
    SELECT COUNT(*) INTO sold_tickets
    FROM tickets
    WHERE event_id = NEW.event_id;
    
    IF (sold_tickets + 1 > venue_capacity) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venue capacity exceeded';
    END IF;
    
    IF (NEW.category = 'VIP') THEN
        SELECT COUNT(*) INTO vip_tickets
        FROM tickets
        WHERE event_id = NEW.event_id AND category = 'VIP';
        
        IF (vip_tickets + 1 > venue_capacity * 0.1) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VIP tickets limited to 10% of venue capacity';
        END IF;
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_visitor_ticket_limit BEFORE INSERT ON visitor_tickets
FOR EACH ROW
BEGIN
    DECLARE event_date DATE;
    DECLARE existing_tickets INT;
    
    SELECT event.event_date INTO event_date
    FROM tickets
    JOIN event ON tickets.event_id = event.id
    WHERE tickets.EAN13 = NEW.ticket_id;
    
    SELECT COUNT(*) INTO existing_tickets
    FROM visitor_tickets
    JOIN tickets ON visitor_tickets.ticket_id = tickets.EAN13
    JOIN event ON tickets.event_id = event.id
    WHERE visitor_tickets.visitor_id = NEW.visitor_id
    AND event.event_date = event_date
    AND tickets.event_id = (SELECT event_id FROM tickets WHERE EAN13 = NEW.ticket_id);
    
    IF (existing_tickets > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Visitor already has a ticket for this event on this date';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_artist_simultaneous_performances BEFORE INSERT ON performance_artistband
FOR EACH ROW
BEGIN
    DECLARE perf_start TIME;
    DECLARE perf_end TIME;
    DECLARE perf_date DATE;
    DECLARE perf_event INT;
    DECLARE conflict_count INT;
    
    SELECT performance.start_time, 
           ADDTIME(performance.start_time, performance.duration),
           event.event_date,
           performance.event_id
    INTO perf_start, perf_end, perf_date, perf_event
    FROM performance
    JOIN event ON performance.event_id = event.id
    WHERE performance.id = NEW.performance_id;
    
    SELECT COUNT(*) INTO conflict_count
    FROM performance_artistband
    JOIN performance ON performance_artistband.performance_id = performance.id
    JOIN event ON performance.event_id = event.id
    WHERE performance_artistband.artist_band_id = NEW.artist_band_id
    AND event.event_date = perf_date
    AND performance.id != NEW.performance_id
    AND (
        (performance.start_time <= perf_start AND ADDTIME(performance.start_time, performance.duration) > perf_start)
        OR
        (performance.start_time < perf_end AND ADDTIME(performance.start_time, performance.duration) >= perf_end)
        OR
        (performance.start_time >= perf_start AND ADDTIME(performance.start_time, performance.duration) <= perf_end)
    );
    
    IF (conflict_count > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artist cannot perform on two stages simultaneously';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_artist_consecutive_years BEFORE INSERT ON performance_artistband
FOR EACH ROW
BEGIN
    DECLARE consecutive_years INT;
    
    SELECT COUNT(DISTINCT festival.year) INTO consecutive_years
    FROM performance_artistband
    JOIN performance ON performance_artistband.performance_id = performance.id
    JOIN event ON performance.event_id = event.id
    JOIN festival ON event.festival_year = festival.year
    WHERE performance_artistband.artist_band_id = NEW.artist_band_id
    AND festival.year BETWEEN 
        (SELECT festival.year - 2 FROM performance 
         JOIN event ON performance.event_id = event.id
         JOIN festival ON event.festival_year = festival.year
         WHERE performance.id = NEW.performance_id)
        AND
        (SELECT festival.year FROM performance 
         JOIN event ON performance.event_id = event.id
         JOIN festival ON event.festival_year = festival.year
         WHERE performance.id = NEW.performance_id);
    
    IF (consecutive_years >= 3) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artist cannot perform for more than 3 consecutive years';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_staff_requirements BEFORE INSERT ON event_staff
FOR EACH ROW
BEGIN
    DECLARE venue_capacity INT;
    DECLARE security_count INT;
    DECLARE support_count INT;
    DECLARE staff_role VARCHAR(50);
    
    SELECT role INTO staff_role FROM staff WHERE id = NEW.staff_id;
    
    IF (staff_role = 'security' OR staff_role = 'support') THEN
        SELECT venue.max_capacity INTO venue_capacity
        FROM event
        JOIN event_venue ON event.id = event_venue.event_id
        JOIN venue ON event_venue.venue_id = venue.id
        WHERE event.id = NEW.event_id;
        
        SELECT COUNT(*) INTO security_count
        FROM event_staff
        JOIN staff ON event_staff.staff_id = staff.id
        WHERE event_staff.event_id = NEW.event_id
        AND staff.role = 'security'
        AND event_staff.assignment_date = NEW.assignment_date;
        
        SELECT COUNT(*) INTO support_count
        FROM event_staff
        JOIN staff ON event_staff.staff_id = staff.id
        WHERE event_staff.event_id = NEW.event_id
        AND staff.role = 'support'
        AND event_staff.assignment_date = NEW.assignment_date;
        
        IF (staff_role = 'security') THEN
            SET security_count = security_count + 1;
        ELSEIF (staff_role = 'support') THEN
            SET support_count = support_count + 1;
        END IF;
        
        IF ((security_count / venue_capacity) < 0.05) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Security staff must be at least 5% of venue capacity';
        END IF;
        
        IF ((support_count / venue_capacity) < 0.02) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Support staff must be at least 2% of venue capacity';
        END IF;
    END IF;
END//
DELIMITER ;

CREATE INDEX idx_visitor_name ON visitor(last_name, first_name);
CREATE INDEX idx_artistband_name ON artistband(name);
CREATE INDEX idx_artistband_type ON artistband(type);
CREATE INDEX idx_genre_name ON genre(genre_name);
CREATE INDEX idx_tickets_event ON tickets(event_id);
CREATE INDEX idx_tickets_category ON tickets(category);
CREATE INDEX idx_event_date ON event(event_date);
CREATE INDEX idx_event_festival ON event(festival_year);
CREATE INDEX idx_performance_event ON performance(event_id);
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_staff_experience ON staff(experience_level);
CREATE INDEX idx_evaluation_overall ON evaluation(overall_impression);
CREATE INDEX idx_evaluation_artist ON evaluation(artist_performance);
CREATE INDEX idx_tickets_purchase ON tickets(purchase_date);
CREATE INDEX idx_tickets_payment ON tickets(payment_method);