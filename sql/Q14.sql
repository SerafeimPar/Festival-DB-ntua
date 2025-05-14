WITH genre_appearances AS (
    SELECT 
        g.id AS genre_id,
        g.genre_name,
        e.festival_year,
        COUNT(DISTINCT p.id) AS appearance_count
    FROM 
        genre g
    JOIN 
        artist_band_genre abg ON g.id = abg.genre_id
    JOIN 
        performance_artistband pa ON abg.artist_band_id = pa.artist_band_id
    JOIN 
        performance p ON pa.performance_id = p.id
    JOIN 
        event e ON p.event_id = e.id
    GROUP BY 
        g.id, g.genre_name, e.festival_year
    HAVING 
        appearance_count >= 3
)
SELECT 
    ga1.genre_name,
    ga1.festival_year AS year1,
    ga2.festival_year AS year2,
    ga1.appearance_count
FROM 
    genre_appearances ga1
JOIN 
    genre_appearances ga2 ON ga1.genre_id = ga2.genre_id 
        AND ga1.appearance_count = ga2.appearance_count
        AND ga2.festival_year = ga1.festival_year + 1
ORDER BY 
    ga1.genre_name, ga1.festival_year;