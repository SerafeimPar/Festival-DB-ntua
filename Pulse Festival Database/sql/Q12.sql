SELECT
    DATE(es.shift_start) AS festival_date,
    SUM(CASE WHEN s.role = 'security' THEN 1 ELSE 0 END) AS security_needed,
    SUM(CASE WHEN s.role = 'support' THEN 1 ELSE 0 END) AS support_needed,
    SUM(CASE WHEN s.role = 'technical' THEN 1 ELSE 0 END) AS technical_needed,
    COUNT(DISTINCT s.id) AS overall_needed
FROM 
    festival f
JOIN 
    event e ON f.year = e.festival_year
JOIN 
    event_staff es ON e.id = es.event_id
JOIN 
    staff s ON es.staff_id = s.id
GROUP BY 
    f.year, DATE(es.shift_start)
ORDER BY 
    f.year, festival_date;