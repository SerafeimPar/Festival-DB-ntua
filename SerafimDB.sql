DROP TABLE IF EXISTS Events; 
/*
From relational model delete the equipment table
*/
create table Events
    (ID int auto increment,
     festival_id int, 
     Name varchar(20),
     event_date date CHECK (), 
     start_time time CHECK (start_time >= '00:00:00' AND start_time <= '23:59:59'),
     end_time time CHECK (end_time >= '00:00:00' AND end_time <= '23:59:59'),
     duration time GENERATED ALWAYS AS (TIMEDIFF(end_time, start_time)) STORED,
     primary key(ID),
     foreign key(festival_id) references Festival(year)
    )
);
-- FROM JASON

DROP TABLE IF EXISTS 'Performance'
CREATE TABLE Performance(
		ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
		event_id INT UNSIGNED NOT NULL,
		performance_type VARCHAR(25) NOT NULL,
		venue_id INT UNSIGNED NOT NULL,
		start_time TIME NOT NULL CHECK (start_time BETWEEN '00:00:00' AND '23:59:59'),
		duration TIME NOT NULL CHECK (duration <= '3:00:00'),
		artist_id INT UNSIGNED NOT NULL,
		break TIME NOT NULL CHECK (break BETWEEN '00:05:00' AND '00:30:00'),
		PRIMARY KEY (ID),
		FOREIGN KEY (event_id) REFERENCES Event(ID),
		ON DELETE RESTRICT,
		FOREIGN KEY (venue_id) REFERENCES Venue(ID),
		ON DELETE RESTRICT,
		FOREIGN KEY (artist_id) REFERENCES Artist_Band(ID),
		ON DELETE RESTRICT
	);
	-- Check if ON UPDATE and ON DELETE triggers are correct

DROP TABLE IF EXISTS 'Artist_Band'
CREATE TABLE Artist_Band(
		ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
		type VARCHAR(6) NOT NULL CHECK (type = 'Artist' OR 'Band'),
		name VARCHAR(100) NOT NULL,
		alias VARCHAR(100) UNIQUE,
		born_formed DATE CHECK(),
		website VARCHAR(255) NOT NULL CHECK (website like 'https://%'),
		instagram_profile VARCHAR(255) NOT NULL UNIQUE CHECK (instagram_profile like 'https://www.instagram.com/%'),
		PRIMARY KEY (ID)
); -- Members and Genres are viewed through their respective junction tables

DROP TABLE IF EXISTS 'Member';
CREATE TABLE Member (
    artist_id INT UNSIGNED NOT NULL,
    band_id INT UNSIGNED NOT NULL,
    join_date DATE NOT NULL,
    role VARCHAR(100) NOT NULL,
    PRIMARY KEY (artist_id, band_id),
    FOREIGN KEY (artist_id) REFERENCES Artist_Band(ID) ON DELETE CASCADE,
    FOREIGN KEY (band_id) REFERENCES Artist_Band(ID) ON DELETE CASCADE,
    CHECK (artist_id <> band_id)
);

DROP TABLE IF EXISTS 'Genre';
CREATE TABLE Genre (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    genre VARCHAR(100) NOT NULL,
    sub_genre VARCHAR(100),
    PRIMARY KEY (id),
    UNIQUE (genre, sub_genre)
);

DROP TABLE IF EXISTS 'Artist_Band_Genre';
CREATE TABLE Artist_Band_Genre (
    artist_band_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (artist_band_id, genre_id),
    FOREIGN KEY (artist_band_id) REFERENCES Artist_Band(ID) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(id) ON DELETE CASCADE
);
-- Above Table is used so that Artists/Bands can have multiple Genres
