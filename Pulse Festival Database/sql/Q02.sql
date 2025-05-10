SET @year = 2024;
SET @genre = 'Rock';

SELECT 
    a.id, 
    a.name, 
    a.type, 
    g.genre_name, 
    CASE 
        WHEN e.festival_year = (@year - 2018) THEN 'Yes' 
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
    g.genre_name = @genre
GROUP BY 
    a.id, 
    a.name, 
    a.type, 
    g.genre_name 
ORDER BY 
    a.name;
