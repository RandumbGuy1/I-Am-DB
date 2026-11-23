USE iam_db;
SET SQL_SAFE_UPDATES = 0;

UPDATE imdb_top_1000_final SET
    Certificate = NULLIF(Certificate, ''),
    Meta_score = NULLIF(Meta_score , ''),
    Gross = NULLIF(Gross, '');

UPDATE rotten_tomatoes_final SET
    critics_consensus = NULLIF(critics_consensus, ''),
    genre = NULLIF(genre, ''),
    directors = NULLIF(directors, ''),
    writers = NULLIF(writers, ''),
    release_year = NULLIF(release_year, ''),
    on_streaming_date = NULLIF(on_streaming_date, ''),
    runtime_in_minutes = NULLIF(runtime_in_minutes, ''),
    studio_name = NULLIF(studio_name, ''),
    audience_rating = NULLIF(audience_rating, ''),
    audience_count = NULLIF(audience_count, '');

UPDATE celebrity_data_final SET
    Date_of_birth = NULLIF(Date_of_birth, ''),
    height = NULLIF(height, ''),
    Awards = NULLIF(Awards, ''),
    Birth_place = NULLIF(Birth_place, '');