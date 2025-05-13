DROP SCHEMA if exists `music_festival`;
CREATE SCHEMA `music_festival`;
use music_festival;



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


DROP TABLE IF EXISTS location;
CREATE TABLE location (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(255) NOT NULL,
    geo_coordinates VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    continent VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);



DROP TABLE IF EXISTS images;
CREATE TABLE images (
    image_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    description TEXT NOT NULL,
    image_file BLOB NOT NULL, 
    PRIMARY KEY (image_id)
);



DROP TABLE IF EXISTS locationPhotos;
CREATE TABLE locationPhotos(
    location_id INT UNSIGNED,
    photo INT UNSIGNED,
    FOREIGN KEY (location_id) REFERENCES location(id),
    FOREIGN KEY (photo) REFERENCES images(image_id)
);



DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,
    parent_genre VARCHAR(50),
    PRIMARY KEY (id),
    UNIQUE (genre_name, parent_genre)
);



DROP TABLE IF EXISTS artistband;
CREATE TABLE artistband (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type VARCHAR(6) NOT NULL CHECK (type IN ('Artist', 'Band')),
    name VARCHAR(100) NOT NULL,
    alias VARCHAR(100) UNIQUE,
    birthdate_formation_date DATE NOT NULL,
    website VARCHAR(255) CHECK (website LIKE 'http%'),
    instagram VARCHAR(255) UNIQUE CHECK (instagram LIKE 'https://www.instagram.com/%'),
    image INT UNSIGNED,
    PRIMARY KEY (id),
    FOREIGN KEY (image) references images(image_id)
);




DROP TABLE IF EXISTS artist_band_genre;
CREATE TABLE artist_band_genre (
    artist_band_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (artist_band_id, genre_id),
    FOREIGN KEY (artist_band_id) REFERENCES artistband(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE CASCADE
);




DROP TABLE IF EXISTS memberof;
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



DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
    year INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration INT GENERATED ALWAYS AS (DATEDIFF(end_date, start_date) + 1) STORED,
    location_id INT UNSIGNED NOT NULL,
    poster INT UNSIGNED,
    PRIMARY KEY (year),
    CHECK (start_date <= end_date),
    FOREIGN KEY (location_id) REFERENCES location(id),
    FOREIGN KEY (poster) REFERENCES images(image_id)
);


DROP TABLE IF EXISTS festivalPhotos;
CREATE TABLE festivalPhotos(
    festival_year INT,
    photo INT UNSIGNED,
    FOREIGN KEY (festival_year) REFERENCES festival(year),
    FOREIGN KEY (photo) REFERENCES images(image_id)
);





DROP TABLE IF EXISTS event;
CREATE TABLE event (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    festival_year INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration TIME GENERATED ALWAYS AS (TIMEDIFF(end_time, start_time)) STORED,
    poster INT UNSIGNED, 
    PRIMARY KEY (id),
    FOREIGN KEY (festival_year) REFERENCES festival(year),
    CHECK (start_time < end_time),
    FOREIGN KEY (poster) REFERENCES images(image_id)
);

DROP TABLE IF EXISTS venue;
CREATE TABLE venue (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT UNSIGNED NOT NULL,
    technical_requirements TEXT,
    photo INT UNSIGNED, 
    FOREIGN KEY (photo) REFERENCES images(image_id),
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS event_venue;
CREATE TABLE event_venue (
    event_id INT UNSIGNED NOT NULL,
    venue_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (event_id, venue_id),
    FOREIGN KEY (event_id) REFERENCES event(id),
    FOREIGN KEY (venue_id) REFERENCES venue(id)
);

DROP TABLE IF EXISTS performance;
CREATE TABLE performance (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id INT UNSIGNED NOT NULL,
    venue_id INT UNSIGNED NOT NULL,
    performance_type VARCHAR(50) NOT NULL CHECK (performance_type IN ('warm up', 'headline', 'Special guest', 'other')),
    start_time DATETIME NOT NULL,
    duration TIME NOT NULL CHECK (duration <= '03:00:00'),
    sequence_number INT UNSIGNED NOT NULL,
    break_duration TIME NOT NULL CHECK (break_duration BETWEEN '00:05:00' AND '00:30:00'),
    PRIMARY KEY (id),
    FOREIGN KEY (event_id, venue_id) REFERENCES event_venue(event_id, venue_id),
    UNIQUE (event_id, venue_id, sequence_number)
);

DROP TABLE IF EXISTS performance_artistband;
CREATE TABLE performance_artistband (
    performance_id INT UNSIGNED NOT NULL,
    artist_band_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (performance_id, artist_band_id),
    FOREIGN KEY (performance_id) REFERENCES performance(id),
    FOREIGN KEY (artist_band_id) REFERENCES artistband(id)
);


DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age TINYINT UNSIGNED NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('technical', 'security', 'support')),
    experience_level VARCHAR(20) NOT NULL CHECK (experience_level IN ('trainee', 'beginner', 'intermediate', 'experienced', 'expert')),
    PRIMARY KEY (id)
);


DROP TABLE IF EXISTS event_staff;
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


DROP TABLE IF EXISTS tickets;
CREATE TABLE tickets (
    EAN13 CHAR(13) NOT NULL CHECK (EAN13 REGEXP '^[0-9]{13}$'),
    visitor_id INT UNSIGNED,
    category VARCHAR(3) NOT NULL CHECK (category IN ('GA', 'VIP', 'BaS')),
    purchase_date DATE NOT NULL,
    price DECIMAL(6,2) UNSIGNED NOT NULL,
    payment_method CHAR(2) NOT NULL CHECK (payment_method IN ('CC', 'DC', 'BC', 'NC')),
    isActivated BOOLEAN NOT NULL DEFAULT 0,
    event_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (EAN13),
    FOREIGN KEY (event_id) REFERENCES event(id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id)
);

DROP TABLE IF EXISTS buyer_queue;
CREATE TABLE buyer_queue (
    buy_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    event_id INT UNSIGNED NOT NULL,
    ticket_type VARCHAR(3) NOT NULL CHECK (ticket_type IN ('GA', 'VIP', 'BaS', 'Any')),  
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'cancelled')),
    PRIMARY KEY (buy_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (event_id) REFERENCES event(id),
    UNIQUE(visitor_id,event_id)
);

DROP TABLE IF EXISTS seller_queue;
CREATE TABLE seller_queue (
    sell_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    ticket_id CHAR(13) NOT NULL,
    list_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sold', 'cancelled')),
    PRIMARY KEY (sell_id), 
    FOREIGN KEY (visitor_id) REFERENCES visitor(id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(EAN13),
    UNIQUE(visitor_id,ticket_id)
);

DROP TABLE IF EXISTS resale_transactions;
CREATE TABLE resale_transactions (
    complete_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    buyer_id INT UNSIGNED NOT NULL,
    seller_id INT UNSIGNED NOT NULL,
    transaction_date DATETIME NOT NULL,
    event_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (complete_id),
    FOREIGN KEY (buyer_id) REFERENCES visitor(id),
    FOREIGN KEY (seller_id) REFERENCES visitor(id),
    FOREIGN KEY (event_id) REFERENCES event(id)
);



DROP TABLE IF EXISTS evaluation ;
CREATE TABLE evaluation (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    artist_performance TINYINT UNSIGNED NOT NULL CHECK (artist_performance BETWEEN 1 AND 5),
    sound_lighting TINYINT UNSIGNED NOT NULL CHECK (sound_lighting BETWEEN 1 AND 5),
    stage_presence TINYINT UNSIGNED NOT NULL CHECK (stage_presence BETWEEN 1 AND 5),
    organization TINYINT UNSIGNED NOT NULL CHECK (organization BETWEEN 1 AND 5),
    overall_impression TINYINT UNSIGNED NOT NULL CHECK (overall_impression BETWEEN 1 AND 5),
    PRIMARY KEY (id)
);


DROP TABLE IF EXISTS rates;
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


DELIMITER //
CREATE TRIGGER check_visitor_has_activated_ticket BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    DECLARE ticket_count INT;
    
    SELECT COUNT(*) INTO ticket_count
    FROM tickets
    JOIN event ON tickets.event_id = event.id
    JOIN performance ON event.id = performance.event_id
    WHERE tickets.visitor_id = NEW.visitor_id
    AND performance.id = NEW.performance_id
    AND tickets.isActivated = 1;
    
    IF (ticket_count = 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Visitor must have an activated ticket to rate a performance';
    END IF;
END//
    

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



CREATE TRIGGER check_visitor_ticket_limit BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    DECLARE ticket_date DATE;
    DECLARE existing_tickets INT;
    
    SELECT event_date INTO ticket_date
    FROM event
    where id = NEW.event_id;
    
    SELECT COUNT(*) INTO existing_tickets
    FROM tickets JOIN event on (tickets.event_id = event.id)
    WHERE tickets.visitor_id = NEW.visitor_id
    AND ticket_date = event.event_date;
    
    IF (existing_tickets > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Visitor already has a ticket for this event on this date';
    END IF;
END//



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


CREATE TRIGGER check_staff_requirements_before_ticket BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    DECLARE venue_capacity INT;
    DECLARE security_count INT;
    DECLARE support_count INT;
    DECLARE event_date DATE;
    
    -- Get the event date
    SELECT e.event_date INTO event_date
    FROM event e
    WHERE e.id = NEW.event_id;
    
    -- Get venue capacity
    SELECT venue.max_capacity INTO venue_capacity
    FROM event
    JOIN event_venue ON event.id = event_venue.event_id
    JOIN venue ON event_venue.venue_id = venue.id
    WHERE event.id = NEW.event_id;
    
    -- Count security staff for this event and date
    SELECT COUNT(DISTINCT staff_id) INTO security_count
    FROM event_staff
    JOIN staff ON event_staff.staff_id = staff.id
    WHERE event_staff.event_id = NEW.event_id
    AND staff.role = 'security';
    
    -- Count support staff for this event and date
    SELECT COUNT(DISTINCT staff_id) INTO support_count
    FROM event_staff
    JOIN staff ON event_staff.staff_id = staff.id
    WHERE event_staff.event_id = NEW.event_id
    AND staff.role = 'support';
    
    -- Debug output
    SET @debug_msg = CONCAT('Venue capacity: ', venue_capacity, 
                           ', Security count: ', security_count, 
                           ', Support count: ', support_count,
                           ', Security ratio: ', CAST((security_count * 100 / venue_capacity) AS DECIMAL(10,2)), '%',
                           ', Support ratio: ', CAST((support_count * 100 / venue_capacity) AS DECIMAL(10,2)), '%');
    
    -- Use float division and convert to decimal to avoid integer division
    IF ((security_count * 100 / venue_capacity) < 5) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot sell tickets: Security staff must be at least 5% of venue capacity';
    END IF;
    
    IF ((support_count * 100 / venue_capacity) < 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot sell tickets: Support staff must be at least 2% of venue capacity';
    END IF;
END//


DROP PROCEDURE IF EXISTS Q02//


CREATE PROCEDURE Q02 (IN in_genre_name VARCHAR(50), IN in_year int)
BEGIN
SELECT 
    a.id, 
    a.name, 
    a.type, 
    g.genre_name, 
    CASE 
        WHEN e.festival_year = (in_year - 2018) THEN 'Yes' 
        ELSE 'No' 
    END AS participated_in_festival_in_year_specified
FROM 
    artistband a 
    JOIN artist_band_genre abg ON a.id = abg.artist_band_id 
    JOIN genre g ON abg.genre_id = g.id 
    LEFT JOIN performance_artistband pa ON a.id = pa.artist_band_id 
    LEFT JOIN performance p ON pa.performance_id = p.id 
    LEFT JOIN event e ON p.event_id = e.id 
WHERE 
    g.genre_name = in_genre_name
GROUP BY 
    a.id, 
    a.name, 
    a.type, 
    g.genre_name 
ORDER BY 
    a.name;
END//


DROP PROCEDURE IF EXISTS Q04//


CREATE PROCEDURE Q04 (IN in_artist_alias VARCHAR(100))
BEGIN
SELECT 
    ab.id, 
    ab.alias,
    ab.type,
    AVG(e.artist_performance) AS Artist_Performance, 
    AVG(e.overall_impression) AS Overall_Impression
FROM 
    artistband ab
JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id
JOIN 
    performance p ON pa.performance_id = p.id
JOIN 
    rates r ON p.id = r.performance_id
JOIN 
    evaluation e ON r.evaluation_id = e.id
WHERE 
    ab.alias = in_artist_alias
GROUP BY 
    ab.id, ab.alias, ab.type;
END//


DROP PROCEDURE IF EXISTS Q06//

CREATE PROCEDURE Q06 (IN in_last_name VARCHAR(50), IN in_first_name VARCHAR(50))
BEGIN
SELECT 
    v.id AS visitor_id,
    v.first_name,
    v.last_name,
    ab.name AS Artist_name,
    e.name AS Event_name,
    e.event_date,
    AVG(eval.overall_impression) AS Overall_impression
FROM 
    tickets t
JOIN 
    visitor v ON t.visitor_id = v.id
JOIN 
    event e ON t.event_id = e.id
JOIN 
    performance p ON e.id = p.event_id
JOIN 
    performance_artistband pa ON p.id = pa.performance_id
JOIN 
    artistband ab ON pa.artist_band_id = ab.id
LEFT JOIN 
    rates r ON v.id = r.visitor_id AND p.id = r.performance_id
LEFT JOIN 
    evaluation eval ON r.evaluation_id = eval.id
WHERE 
    v.first_name = in_first_name AND v.last_name = in_last_name
GROUP BY 
    v.id, v.first_name, v.last_name, ab.name, e.name, e.event_date
ORDER BY 
    e.event_date, p.start_time;

END//



DROP PROCEDURE IF EXISTS Q08//

CREATE PROCEDURE Q08 (IN in_date DATE)
BEGIN
SELECT 
    s.id, 
    s.name, 
    s.age, 
    s.experience_level
FROM 
    staff s
WHERE 
    s.role = 'support' 
    AND s.id NOT IN (
        SELECT 
            es.staff_id 
        FROM 
            event_staff es 
        WHERE 
            DATE(es.shift_start) = in_date
    )
ORDER BY 
    s.id;

END//

CREATE TRIGGER auto_buyer_transaction AFTER INSERT ON buyer_queue
FOR EACH ROW
BEGIN
    DECLARE sell INT;
    DECLARE seller_id INT;
    
    IF (NEW.status = 'pending') THEN
        SELECT sellQ.sell_id, sellQ.visitor_id INTO sell,seller_id
        FROM seller_queue as sellQ JOIN tickets on ticket_id = EAN13
        WHERE sellQ.status = 'pending' AND NEW.event_id = tickets.event_id AND (NEW.ticket_type = 'Any' OR NEW.ticket_type = ticket.category)
        ORDER BY sellQ.seller_id
        LIMIT 1;

        IF sell IS NOT NULL THEN
            UPDATE seller_queue
            SET status = 'completed'
            WHERE sell_id = sell;
            
            UPDATE buyer_queue 
            SET status = 'completed'
            WHERE buy_id = NEW.buy_id;

            INSERT INTO resale_transactions (buyer_id,seller_id,event_id,transaction_date) VALUES (NEW.visitor_id,seller_id,NEW.event_id,NOW()); 
        END IF;
    END IF;


END//


CREATE TRIGGER auto_seller_transaction AFTER INSERT ON seller_queue
FOR EACH ROW
BEGIN
    DECLARE buy INT;
    DECLARE buyer_id INT;
    DECLARE event_id INT;
    
    IF (NEW.status = 'pending') THEN
        SELECT buyQ.sell_id,buyQ.visitor_id,buyQ.event_id INTO buy,buyer_id,event_id
        FROM buyer_queue as buyQ, tickets
        WHERE  NEW.ticket_id = EAN13 AND buyerQ.status = 'pending' AND tickets.event_id = buyerQ.event_id AND (buyerQ.ticket_type = 'Any' OR ticket.category = buyerQ.ticket_type)
        ORDER BY sellQ.seller_id
        LIMIT 1;

        IF buy IS NOT NULL THEN
            UPDATE buyer_queue
            SET status = 'completed'
            WHERE buy_id = buy;
            
            UPDATE seller_queue 
            SET status = 'completed'
            WHERE sell = NEW.sell_id;

            INSERT INTO resale_transactions (buyer_id,seller_id,event_id,transaction_date) VALUES (buyer_id,NEW.visitor_id,event_id,NOW()); 
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

