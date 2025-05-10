SELECT 
    e.festival_year, 
    AVG(CASE 
        WHEN s.experience_level = 'trainee' THEN 1 
        WHEN s.experience_level = 'beginner' THEN 2 
        WHEN s.experience_level = 'intermediate' THEN 3 
        WHEN s.experience_level = 'experienced' THEN 4 
        WHEN s.experience_level = 'expert' THEN 5 
        ELSE 0 
    END) AS `avg_experience_value/5`
FROM 
    event e 
JOIN 
    event_staff es ON e.id = es.event_id 
JOIN 
    staff s ON es.staff_id = s.id 
WHERE 
    s.role = 'technical' 
GROUP BY 
    e.festival_year 
ORDER BY 
    `avg_experience_value/5` ASC;
