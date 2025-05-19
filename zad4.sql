-- 1. Ranking pracowników wg pensji
SELECT 
    id,
    first_name,
    last_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- 2. Kolumna z sumą wszystkich pensji
SELECT 
    id,
    first_name,
    last_name,
    salary,
    SUM(salary) OVER () AS total_salary
FROM employees;

-- 3. Skumulowana wartość sprzedaży pracownika i jego ranking
-- Nie można mieć funkcji okienkowej w argumencie innej funkcji okienkowej, rozbijamy na podzapytanie
WITH sales_per_employee AS (
    SELECT
        e.id,
        e.last_name,
        SUM(s.quantity * s.price) AS total_sales
    FROM sales s
    JOIN employees e ON s.employee_id = e.id
    GROUP BY e.id, e.last_name
)
SELECT 
    spe.last_name,
    spe.total_sales,
    RANK() OVER (ORDER BY spe.total_sales DESC) AS sales_rank
FROM sales_per_employee spe;

-- 4. Transakcje i ceny danego dnia, z poprzednią i kolejną ceną
SELECT 
    e.last_name,
    p.name AS product_name,
    s.price,
    COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date) AS transactions_per_day,
    SUM(s.price * s.quantity) OVER (PARTITION BY s.product_id, s.sale_date) AS total_paid_per_day,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS prev_price,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS next_price
FROM sales s
JOIN employees e ON s.employee_id = e.id
JOIN products p ON s.product_id = p.id;

-- 5. Suma i suma rosnąca zapłacona w miesiącu za produkt
-- Oracle nie ma DATE_TRUNC, używamy TRUNC(date, 'MM')
SELECT 
    p.name AS product_name,
    s.price,
    TRUNC(s.sale_date, 'MM') AS sale_month,
    SUM(s.price * s.quantity) OVER (PARTITION BY p.id, TRUNC(s.sale_date, 'MM')) AS total_paid_month,
    SUM(s.price * s.quantity) OVER (PARTITION BY p.id, TRUNC(s.sale_date, 'MM') ORDER BY s.sale_date) AS running_total_month
FROM sales s
JOIN products p ON s.product_id = p.id;

-- 6. Cena z 2022 i 2023 z tego samego dnia oraz różnica, z kategorią
SELECT 
    p.name AS product_name,
    p.category,
    s2022.price AS price_2022,
    s2023.price AS price_2023,
    s2023.price - s2022.price AS price_diff
FROM (
    SELECT product_id, price, sale_date FROM sales WHERE EXTRACT(YEAR FROM sale_date) = 2022
) s2022
JOIN (
    SELECT product_id, price, sale_date FROM sales WHERE EXTRACT(YEAR FROM sale_date) = 2023
) s2023 ON s2022.product_id = s2023.product_id 
   AND EXTRACT(MONTH FROM s2022.sale_date) = EXTRACT(MONTH FROM s2023.sale_date) 
   AND EXTRACT(DAY FROM s2022.sale_date) = EXTRACT(DAY FROM s2023.sale_date)
JOIN products p ON p.id = s2022.product_id;

-- 7. Cena, minimalna i maksymalna w kategorii, różnica
SELECT 
    p.category,
    p.name AS product_name,
    s.price,
    MIN(s.price) OVER (PARTITION BY p.category) AS min_price_in_category,
    MAX(s.price) OVER (PARTITION BY p.category) AS max_price_in_category,
    MAX(s.price) OVER (PARTITION BY p.category) - MIN(s.price) OVER (PARTITION BY p.category) AS price_diff_in_category
FROM sales s
JOIN products p ON s.product_id = p.id;

-- 8. Średnia krocząca (poprzednia, bieżąca, następna)
SELECT 
    p.name AS product_name,
    s.sale_date,
    s.price,
    ROUND(AVG(s.price) OVER (PARTITION BY p.id ORDER BY s.sale_date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 2) AS moving_avg_price
FROM sales s
JOIN products p ON s.product_id = p.id;

-- 9. Ranking, numeracja i dense rank cen w kategorii
SELECT 
    p.name AS product_name,
    p.category,
    s.price,
    RANK() OVER (PARTITION BY p.category ORDER BY s.price DESC) AS price_rank,
    ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY s.price DESC) AS row_number_in_category,
    DENSE_RANK() OVER (PARTITION BY p.category ORDER BY s.price DESC) AS dense_price_rank
FROM sales s
JOIN products p ON s.product_id = p.id;

-- 10. Wartość rosnąca sprzedaży danego pracownika + ranking ogólny
-- Poprawione, bo globalny ranking musi bazować na sumie sprzedaży pracownika, a nie na pojedynczej transakcji
WITH cumulative_sales AS (
    SELECT 
        e.id,
        e.last_name,
        s.sale_date,
        SUM(s.price * s.quantity) OVER (PARTITION BY e.id ORDER BY s.sale_date) AS cumulative_employee_sales
    FROM sales s
    JOIN employees e ON s.employee_id = e.id
)
SELECT
    cs.last_name,
    cs.sale_date,
    cs.cumulative_employee_sales,
    RANK() OVER (ORDER BY cs.cumulative_employee_sales DESC) AS global_sales_rank
FROM cumulative_sales cs;

-- 11. Pracownicy biorący udział w sprzedaży (bez funkcji okienkowych)
SELECT DISTINCT 
    e.first_name,
    e.last_name,
    e.position
FROM employees e
JOIN sales s ON s.employee_id = e.id;
