SELECT 
    e.festival_year AS Year,
    SUM(CASE WHEN t.payment_method = 'CC' THEN t.price ELSE 0 END) AS CC_Revenue,
    SUM(CASE WHEN t.payment_method = 'DC' THEN t.price ELSE 0 END) AS DC_Revenue,
    SUM(CASE WHEN t.payment_method = 'BC' THEN t.price ELSE 0 END) AS BC_Revenue,
    SUM(CASE WHEN t.payment_method = 'NC' THEN t.price ELSE 0 END) AS NC_Revenue,
    SUM(t.price) AS Total_Revenue
FROM 
    tickets t
JOIN 
    event e ON t.event_id = e.id
GROUP BY 
    e.festival_year
ORDER BY 
    e.festival_year;
