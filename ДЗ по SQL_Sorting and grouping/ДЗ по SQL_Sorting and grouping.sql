--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Пункт 1 -----------------------------------------------

-- Запрос для получения количества покупателей по городам и возрастным категориям
SELECT city,
    CASE -- Определяем возрастную категорию на основе возраста пользователя
        WHEN age BETWEEN 0 AND 20 THEN 'young' -- Если возраст от 0 до 20 лет, присваиваем категорию 'young'
        WHEN age BETWEEN 21 AND 49 THEN 'adult' -- Если возраст от 21 до 49 лет, присваиваем категорию 'adult'
        ELSE 'old' -- Если возраст 50 лет и старше, присваиваем категорию 'old'
    END AS age_category,
    COUNT(id) AS user_count -- Считаем количество пользователей в каждой категории
FROM users
GROUP BY city, age_category -- Группируем данные по городу и возрастной категории
ORDER BY user_count DESC; -- Сортируем результаты по количеству пользователей в порядке убывания для определения наиболее крупных групп

--------------------------------- 1 Часть -----------------------------------------------
--------------------------------- Пункт 2 -----------------------------------------------

-- Запрос для расчета средней цены товаров по категориям, где в названии товара содержатся слова 'hair' или 'home'
SELECT category, ROUND(AVG(price), 2) AS avg_price  -- Округляем среднюю цену до двух знаков после запятой и называем столбец avg_price
FROM products
WHERE name ILIKE '%hair%' OR name ILIKE '%home%'  -- Фильтруем товары по наличию слов 'hair' или 'home' в названии
GROUP BY category; -- Группируем результаты по категориям товаров

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 1 -----------------------------------------------

-- Запрос для получения информации о продавцах с более чем одной категорией товаров, исключая категорию 'Bedding'
SELECT seller_id, COUNT(DISTINCT category) AS total_categ, AVG(rating) AS avg_rating, SUM(revenue) AS total_revenue, -- Считаем количество уникальных категорий для каждого продавца, средний рейтинг, суммируем выручку каждого продавца
    CASE
        WHEN SUM(revenue) > 50000 THEN 'rich' -- Если суммарная выручка превышает 50 000, отмечаем как 'rich'
        ELSE 'poor' -- В противном случае отмечаем как 'poor'
    END AS seller_type
FROM sellers
WHERE category != 'Bedding' -- Исключаем категорию 'Bedding' из расчетов
GROUP BY seller_id
HAVING COUNT(DISTINCT category) > 1 -- Оставляем только продавцов с более чем одной категорией
ORDER BY seller_id ASC; -- Сортируем результаты по возрастанию seller_id

-- NB:
-- Продавцы с одной категорией товаров (их условно назвал no_name ), независимо от их выручки
-- не учитываются в данном запросе из-за условия HAVING COUNT(DISTINCT category) > 1
-- Это означает, что даже если их суммарная выручка превышает 50 000, они не будут включены в результаты
-- Не включил их, так как по условию задачи рассматриваются только продавцы, продающие более одной категории товаров и разделяемые на 'rich' и 'poor' на основе выручки 50 000

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 2 -----------------------------------------------

-- Запрос для получения количества полных месяцев с даты регистрации и разницы между максимальным и минимальным сроком доставки для неуспешных продавцов
SELECT seller_id,
       FLOOR((CURRENT_DATE - MIN(TO_DATE(date_reg, 'DD/MM/YYYY'))) / 30)::int AS month_from_registration, -- Вычисляем количество полных месяцев с даты регистрации продавца, считая, что в месяце 30 дней
       (SELECT MAX(delivery_days) - MIN(delivery_days) -- Вычисляем разницу между максимальным и минимальным сроком доставки среди неуспешных продавцов
        FROM sellers
        WHERE category != 'Bedding' -- Исключаем категорию 'Bedding' из расчетов
          AND seller_id IN ( -- Подзапрос для получения seller_id неуспешных продавцов
              SELECT seller_id
              FROM sellers
              WHERE category != 'Bedding'
              GROUP BY seller_id
              HAVING COUNT(DISTINCT category) >= 1 AND SUM(revenue) <= 50000
          )
       ) AS max_delivery_difference
FROM sellers
WHERE category != 'Bedding'
GROUP BY seller_id
HAVING COUNT(DISTINCT category) >= 1 AND SUM(revenue) <= 50000 -- Выбираем продавцов с одной или более категориями и суммарной выручкой не более 50 00
ORDER BY seller_id ASC;   -- Сортируем результаты по возрастанию seller_id

-- NB:
-- Здесь включил продавцов с одной категорией товаров ( их ранее условно называл no_name), предполагая, что они неуспешные
-- Сделали это, так как по условию задачи требуется посчитать для всех неуспешных продавцов, включая тех, кто продает только одну категорию товаров
-- Неуспешными по моему мнению считаются те, у кого количество категорий больше или равно 1 и суммарная выручка менее или равна 50 000
-- Продавцы с одной категорией и выручкой менее или равной 50 000 также включены в результаты как неуспешные продавцы

--------------------------------- 2 Часть -----------------------------------------------
--------------------------------- Пункт 3 -----------------------------------------------

-- Запрос для выбора продавцов, зарегистрированных в 2022 году, которые продают ровно 2 категории товаров с суммарной выручкой более 75 000
SELECT seller_id, string_agg(DISTINCT category, ' - ' ORDER BY category) AS category_pair -- Объединяем названия категорий в одну строку с разделителем ' - ', сортируя категории в алфавитном порядке
FROM sellers
WHERE TO_DATE(date_reg, 'DD/MM/YYYY') >= DATE '2022-01-01' and TO_DATE(date_reg, 'DD/MM/YYYY') < DATE '2023-01-01' -- Отбираем в явном виде продавцов, зарегистрированных в 2022 году
GROUP BY seller_id
HAVING COUNT(DISTINCT category) = 2 AND SUM(revenue) > 75000 -- Оставляем только тех, кто продает ровно 2 различные категории товаров И суммарная выручка которых превышает 75 000
ORDER BY seller_id ASC; -- Сортируем результаты по возрастанию seller_id
