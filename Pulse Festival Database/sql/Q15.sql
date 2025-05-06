SELECT 
    v.id AS visitor_id,
    v.first_name,
    v.last_name,
    ab.id AS artist_id,
    ab.name AS artist_name,
    SUM(e.artist_performance + e.overall_impression) AS total_rating_score
FROM 
    visitor v
JOIN 
    rates r ON v.id = r.visitor_id
JOIN 
    evaluation e ON r.evaluation_id = e.id
JOIN 
    performance p ON r.performance_id = p.id
JOIN 
    performance_artistband pa ON p.id = pa.performance_id
JOIN 
    artistband ab ON pa.artist_band_id = ab.id
GROUP BY 
    v.id, v.first_name, v.last_name, ab.id, ab.name
ORDER BY 
    total_rating_score DESC
LIMIT 5;