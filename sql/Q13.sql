SELECT 
    ab.id, 
    ab.name, 
    ab.type, 
    COUNT(DISTINCT l.continent) AS continent_count
FROM 
    artistband ab
JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id
JOIN 
    performance p ON pa.performance_id = p.id
JOIN 
    event e ON p.event_id = e.id
JOIN 
    festival f ON e.festival_year = f.year
JOIN 
    location l ON f.location_id = l.id
GROUP BY 
    ab.id, ab.name, ab.type
HAVING 
    continent_count >= 3
ORDER BY 
    continent_count DESC, ab.name;