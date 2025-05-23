SELECT 
    v.id AS visitor_id, 
    v.first_name, 
    v.last_name, 
    YEAR(e.event_date) AS year, 
    COUNT(DISTINCT p.id) AS performances_count
FROM 
    visitor v
JOIN 
    tickets t ON v.id = t.visitor_id
JOIN 
    event e ON t.event_id = e.id
JOIN 
    performance p ON e.id = p.event_id
GROUP BY 
    v.id, v.first_name, v.last_name, YEAR(e.event_date)
HAVING 
    performances_count > 3
ORDER BY 
    year, performances_count DESC, v.id;