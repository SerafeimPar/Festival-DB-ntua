SET @visitor_id = 1; --43 and 33 are good examples
SELECT 
    v.id AS visitor_id,
    v.first_name,
    v.last_name,
    p.id AS performance_id,
    ab.name AS artist_name,
    e.name AS event_name,
    e.event_date,
    AVG((eval.artist_performance + eval.sound_lighting + eval.stage_presence + 
         eval.organization + eval.overall_impression) / 5) AS avg_overall_rating
FROM 
    visitor v
JOIN 
    tickets t ON v.id = t.visitor_id
JOIN 
    event e ON t.event_id = e.id
JOIN 
    performance p ON e.id = p.event_id
JOIN 
    performance_artistband pa ON p.id = pa.performance_id
JOIN 
    artistband ab ON pa.artist_band_id = ab.id
LEFT JOIN 
    rates r ON v.id = r.visitor_id AND p.id = r.performance_id
LEFT JOIN 
    evaluation eval ON r.evaluation_id = eval.id
WHERE 
    v.id = @visitor_id
GROUP BY 
    v.id, v.first_name, v.last_name, p.id, ab.name, e.name, e.event_date
ORDER BY 
    e.event_date, p.start_time;