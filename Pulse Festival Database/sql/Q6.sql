SET @visitor_id = 43; --43 and 33 are good examples

SELECT 
    v.id AS visitor_id,
    v.first_name,
    v.last_name,
    p.id AS performance_id,
    ab.name AS artist_name,
    e.name AS event_name,
    e.event_date,
    AVG(eval.artist_performance) AS avg_artist_rating,
    AVG(eval.overall_impression) AS avg_overall_impression
FROM 
    visitor v
JOIN 
    visitor_tickets vt ON v.id = vt.visitor_id
JOIN 
    tickets t ON vt.ticket_id = t.EAN13
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