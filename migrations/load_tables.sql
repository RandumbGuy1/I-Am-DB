USE iam_db;
SET SQL_SAFE_UPDATES = 0;

-- Empty the schema tables
DELETE FROM credits;
DELETE FROM workedOn;
DELETE FROM Movie;
DELETE FROM Celebrity;
DELETE FROM Studio;
DELETE FROM IMDb_Metrics;
DELETE FROM Tomato_Meter_Metrics;
ALTER TABLE Movie AUTO_INCREMENT = 1;
ALTER TABLE Celebrity AUTO_INCREMENT = 1;
ALTER TABLE Studio AUTO_INCREMENT = 1;

-- Insert studios from rotten tomatoes
INSERT INTO Studio (name, country)
SELECT DISTINCT studio_name, studio_country
FROM rotten_tomatoes_final
WHERE studio_name IS NOT NULL;

INSERT INTO Tomato_Meter_Metrics (id, rating, ratingCount, reviewCount)
SELECT DISTINCT id, tomatometer_rating, audience_count, tomatometer_count
FROM rotten_tomatoes_final;

-- Insert IMDB metrics from imdb top 1000
INSERT INTO IMDb_Metrics (id, rating, numVotes, metaScore)
SELECT id, IMDB_Rating, No_of_Votes, Meta_score
FROM imdb_top_1000_final;

-- Insert Celebrity data
INSERT INTO Celebrity (celebrity_rank, full_name, gender, date_of_birth, height)
SELECT
    `Rank`,
    Name,
    gender,
    Date_of_birth,
    height
FROM celebrity_data_final;

-- Insert celebrities from imdb movies
INSERT INTO Celebrity (full_name)
SELECT p.name
FROM (
    SELECT Director AS name FROM imdb_top_1000_final
    UNION SELECT Star1 FROM imdb_top_1000_final
    UNION SELECT Star2 FROM imdb_top_1000_final
    UNION SELECT Star3 FROM imdb_top_1000_final
    UNION SELECT Star4 FROM imdb_top_1000_final
) AS p
WHERE p.name NOT IN (SELECT full_name FROM Celebrity);

-- Insert movies from rotten tomatoes
INSERT INTO Movie (title, releaseYear, certificate, runtime, genre, tmId)
SELECT DISTINCT
    movie_title,
    release_year,
    rating,
    runtime_in_minutes,
    genre,
    id
FROM rotten_tomatoes_final;

-- Add imdb data to movies matching by title and year in rotten tomatoes
UPDATE Movie m
JOIN imdb_top_1000_final i ON i.Series_Title = m.title AND i.Released_Year = m.releaseYear
SET m.IMDBId = i.id,
    m.overview = i.Overview,
    m.gross = i.Gross;

-- Add non matching imdb movies as their own movies
INSERT INTO Movie (title, releaseYear, certificate, runtime, genre, overview, gross, IMDBId)
SELECT
    i.Series_Title,
    i.Released_Year,
    i.Certificate,
    i.Runtime,
    i.Genre,
    i.Overview,
    i.Gross,
    i.id
FROM imdb_top_1000_final i
WHERE i.id NOT IN (SELECT IMDBId FROM Movie WHERE IMDBId IS NOT NULL);

INSERT INTO workedOn (movie_id, studio_id)
SELECT m.id, s.id
FROM rotten_tomatoes_final AS t
JOIN Movie AS m ON t.id = m.tmId
JOIN Studio AS s ON t.id = t.studio_name = s.name;

INSERT INTO credits (movie_id, celebrity_id)
SELECT m.id, c.id
FROM imdb_top_1000_final AS i
JOIN Movie AS m ON i.id = m.IMDBId
JOIN Celebrity AS c ON c.name = i.Director OR c.name = i.Star1 OR c.name = i.Star2 OR c.name = i.Star3 OR c.name = i.Star4;

INSERT INTO credits(movie_id, celebrity_id)
SELECT m.id, c.id
FROM rotten_tomatoes_final AS t
JOIN Movie AS m ON t.id = mtmId
JOIN Celebrity AS c ON c.name LIKE t.directors OR c.name LIKE t.writers;
