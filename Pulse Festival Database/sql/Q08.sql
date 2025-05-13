SET @specific_date = '2020-09-17'; --Francesca Els (id 11) is wokring that day so  good example

SELECT 
    s.id, 
    s.name, 
    s.age, 
    s.experience_level
FROM 
    staff s
WHERE 
    s.role = 'support' 
    AND s.id NOT IN (
        SELECT 
            es.staff_id 
        FROM 
            event_staff es 
        WHERE 
            DATE(es.shift_start) = @specific_date
    )
ORDER BY 
    s.id;