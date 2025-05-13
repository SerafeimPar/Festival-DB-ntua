SELECT 
    ab.id, 
    ab.name, 
    ab.type, 
    COUNT(DISTINCT e.festival_year) AS participation_count,
    (SELECT COUNT(DISTINCT e2.festival_year) 
     FROM artistband ab2
     LEFT JOIN performance_artistband pa2 ON ab2.id = pa2.artist_band_id
     LEFT JOIN performance p2 ON pa2.performance_id = p2.id
     LEFT JOIN event e2 ON p2.event_id = e2.id
     GROUP BY ab2.id
     ORDER BY COUNT(DISTINCT e2.festival_year) DESC
     LIMIT 1) - COUNT(DISTINCT e.festival_year) AS difference_from_max
FROM 
    artistband ab
LEFT JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id
LEFT JOIN 
    performance p ON pa.performance_id = p.id
LEFT JOIN 
    event e ON p.event_id = e.id
GROUP BY 
    ab.id, ab.name, ab.type
HAVING 
    difference_from_max >= -1
ORDER BY 
    participation_count DESC, ab.name;