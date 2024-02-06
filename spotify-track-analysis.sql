-- Create the database
CREATE SCHEMA IF NOT EXISTS `spotify_track_data` DEFAULT CHARACTER SET utf8mb4 ;

-- Use the database
USE spotify_track_data;

-- Create the tables
CREATE TABLE track_detail(
track_ID VARCHAR(30) NOT NULL,
track_name VARCHAR(255) NOT NULL,
artists_name VARCHAR(650) NOT NULL,
track_duration_ms INT,
track_release_date VARCHAR(10),
track_year INT NOT NULL,
PRIMARY KEY (track_ID)
);

CREATE TABLE track_figures(
track_figure_ID INT AUTO_INCREMENT,
track_acousticness DOUBLE,	
track_danceability DOUBLE,
track_energy DOUBLE,
track_instrumentalness DOUBLE,	
track_liveness DOUBLE,
track_loudness DOUBLE,
track_speechiness DOUBLE,
track_tempo DOUBLE,
track_valence	DOUBLE,
track_mode INT,
track_key INT,
track_popularity INT,	
track_explicit INT,
track_ID VARCHAR(30),
PRIMARY KEY (track_figure_ID),
FOREIGN KEY(track_ID) REFERENCES Track_Detail(track_ID)
);

-- import the dataset first table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track_detail.csv'
INTO TABLE track_detail
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- import the dataset inro second table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track_figure.csv'
INTO TABLE track_figures
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;