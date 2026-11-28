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
SELECT DISTINCT tm_id, tomatometer_rating, audience_count, tomatometer_count
FROM rotten_tomatoes_final;

-- Insert IMDB metrics from imdb top 1000
INSERT INTO IMDb_Metrics (id, rating, numVotes, metaScore)
SELECT imdb_id, IMDB_Rating, No_of_Votes, Meta_score
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

-- Insert celebrities rotten tomatoes credits
INSERT INTO Celebrity (full_name)
SELECT DISTINCT name
FROM rotten_tomatoes_credits
WHERE name NOT IN (SELECT full_name FROM Celebrity);

-- Insert movies from rotten tomatoes
INSERT INTO Movie (title, releaseYear, certificate, runtime, genre, tmId)
SELECT DISTINCT
    movie_title,
    release_year,
    rating,
    runtime_in_minutes,
    genre,
    tm_id
FROM rotten_tomatoes_final;

-- Add imdb data to movies matching by title and year in rotten tomatoes
UPDATE Movie m
JOIN imdb_top_1000_final i ON i.Series_Title = m.title AND i.Released_Year = m.releaseYear
SET m.IMDBId = i.imdb_id,
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
    i.imdb_id
FROM imdb_top_1000_final i
WHERE i.imdb_id NOT IN (SELECT IMDBId FROM Movie WHERE IMDBId IS NOT NULL);

-- map studios to rotten tomato movies, rotten_tomatoes_final is the only csv with studio_names
INSERT INTO workedOn (movieId, studioId)
SELECT DISTINCT m.id, s.id
FROM rotten_tomatoes_final AS t
JOIN Movie AS m ON t.tm_id = m.tmId
JOIN Studio AS s ON t.studio_name = s.name;

-- Insert credits from both rotten tomatoes and imdb
-- Group by movieId and celebrityId to avoid dupes
-- Max(Director) means if multiple rows with the same movie id and celebrity id have different isDirector, then we will take 1 over 0
INSERT INTO credits (movieId, celebrityId, isDirector)
SELECT movieId, celebrityId, MAX(isDirector)
FROM (
    SELECT m.id AS movieId, c.id AS celebrityId, c.full_name = i.Director AS isDirector
    FROM imdb_top_1000_final AS i
    JOIN Movie AS m ON m.IMDBId = i.imdb_id
    JOIN Celebrity AS c ON c.full_name IN (i.Director, i.Star1, i.Star2, i.Star3, i.Star4)

    UNION ALL

    SELECT m.id, c.id, r.is_director
    FROM rotten_tomatoes_credits AS r
    JOIN Movie AS m ON m.tmId = r.tm_id
    JOIN Celebrity AS c ON c.full_name = r.name
) AS all_credits
GROUP BY movieId, celebrityId;