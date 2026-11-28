CREATE SCHEMA `iam_db`;
USE iam_db;

CREATE TABLE Studio(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(100)
);

CREATE TABLE Celebrity(
	id INT AUTO_INCREMENT PRIMARY KEY,
    celebrity_rank INT,
    full_name VARCHAR(255) NOT NULL,
    gender VARCHAR(20),
    date_of_birth DATE,
    height DECIMAL(5, 2)
);

-- ID from imdb_top_1000 is this id, it has to be on that table so rotten tomato movies
-- can be linked to their corresponding imdb_id by matching on title and year
CREATE TABLE IMDb_Metrics (
    id INT PRIMARY KEY,
    rating DECIMAL(3, 1),
    numVotes INT,
    metaScore INT
);

-- ID from rotten_tomatoes is this id, was needed since theres multiple rows with
-- the same movie but differrent studios
CREATE TABLE Tomato_Meter_Metrics (
    id INT PRIMARY KEY,
    rating INT,
    ratingCount INT,
    reviewCount INT
);

CREATE TABLE Movie(
	id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    releaseYear INT,
    certificate VARCHAR(10),
    runtime INT,
	genre VARCHAR(150),
    overview VARCHAR(2500),
    gross DECIMAL(15, 2),
    studioID INT,
	IMDBId INT UNIQUE,
    tmId INT UNIQUE,
    CONSTRAINT fk_movie_imdb FOREIGN KEY (IMDbId) REFERENCES IMDb_Metrics(id),
    CONSTRAINT fk_movie_tm FOREIGN KEY (tmId) REFERENCES Tomato_Meter_Metrics(id)
);

-- Intermediate tables -------------
CREATE TABLE workedOn (
    movieId INT NOT NULL,
    studioId INT NOT NULL,
    PRIMARY KEY (movieId, studioId),
    CONSTRAINT fk_workedon_movie FOREIGN KEY (movieId) REFERENCES Movie(id),
    CONSTRAINT fk_workedon_studio FOREIGN KEY (studioId) REFERENCES Studio(id)
);

CREATE TABLE credits (
    movieId INT NOT NULL,
    celebrityId INT NOT NULL,
    isDirector BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (movieId, celebrityId),
    CONSTRAINT fk_credits_movie FOREIGN KEY (movieId) REFERENCES Movie(id),
    CONSTRAINT fk_credits_celebrity FOREIGN KEY (celebrityId) REFERENCES Celebrity(id)
);