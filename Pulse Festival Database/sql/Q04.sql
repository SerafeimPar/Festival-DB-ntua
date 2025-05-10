SET @artist_id = 15;

SELECT 
    ab.id, 
    ab.name, 
    ab.type, 
    AVG(e.artist_performance) AS avg_artist_performance, 
    AVG(e.overall_impression) AS avg_overall_impression
FROM 
    artistband ab
JOIN 
    performance_artistband pa ON ab.id = pa.artist_band_id
JOIN 
    performance p ON pa.performance_id = p.id
JOIN 
    rates r ON p.id = r.performance_id
JOIN 
    evaluation e ON r.evaluation_id = e.id
WHERE 
    ab.id = @artist_id
GROUP BY 
    ab.id, ab.name, ab.type;
