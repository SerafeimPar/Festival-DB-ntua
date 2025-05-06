SELECT 
    ab.id, 
    ab.name, 
    ab.type,
    TIMESTAMPDIFF(YEAR, ab.birthdate_formation_date, CURDATE()) AS age,
    COUNT(DISTINCT e.festival_year) AS festival_participations
FROM 
    artistband ab
JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id
JOIN 
    performance p ON pa.performance_id = p.id
JOIN 
    event e ON p.event_id = e.id
WHERE 
    ab.type = 'Artist' AND
    TIMESTAMPDIFF(YEAR, ab.birthdate_formation_date, CURDATE()) < 30
GROUP BY 
    ab.id, ab.name, ab.type, age
ORDER BY 
    festival_participations DESC, ab.name;