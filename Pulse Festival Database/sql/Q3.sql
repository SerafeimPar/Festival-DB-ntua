SELECT 
    ab.id, 
    ab.name, 
    ab.type, 
    e.festival_year, 
    COUNT(*) AS warm_up_count 
FROM 
    artistband ab 
JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id 
JOIN 
    performance p ON pa.performance_id = p.id 
JOIN 
    event e ON p.event_id = e.id 
GROUP BY 
    ab.id, ab.name, ab.type, e.festival_year 
HAVING 
    COUNT(*) > 2 
ORDER BY 
    COUNT(*) DESC, e.festival_year, ab.name;