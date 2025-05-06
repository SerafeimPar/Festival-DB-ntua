SELECT 
    g1.genre_name AS genre1, 
    g2.genre_name AS genre2, 
    COUNT(DISTINCT pa.artist_band_id) AS artist_count
FROM 
    artist_band_genre abg1
JOIN 
    genre g1 ON abg1.genre_id = g1.id
JOIN 
    artist_band_genre abg2 ON abg1.artist_band_id = abg2.artist_band_id AND abg1.genre_id < abg2.genre_id
JOIN 
    genre g2 ON abg2.genre_id = g2.id
JOIN 
    performance_artistband pa ON abg1.artist_band_id = pa.artist_band_id
GROUP BY 
    g1.genre_name, g2.genre_name
ORDER BY 
    artist_count DESC
LIMIT 3;