-- 1. Для Олимпийских игр 2004 года сгенерируйте список (год рождения, количество игроков, количество золотых медалей),
--    содержащий годы, в которые родились игроки, количество игроков, родившихся в каждый из этих лет,
--    которые выиграли по крайней мере одну золотую медаль, и количество золотых медалей, завоеванных игроками, родившимися в этом году.

SELECT
    EXTRACT(YEAR FROM p.birthdate) AS birth_year,
    COUNT(DISTINCT p.player_id) AS player_count,
    COUNT(r.medal) AS gold_medal_count
FROM
    players p
JOIN
    results r ON p.player_id = r.player_id
JOIN
    events e ON r.event_id = e.event_id
JOIN
    olympics o ON e.olympic_id = o.olympic_id
WHERE
    o.year = 2004
    AND r.medal = 'GOLD'
GROUP BY
    birth_year
ORDER BY
    birth_year;

-- 2. Перечислите все индивидуальные (не групповые) соревнования, в которых была ничья в счете,
--    и два или более игрока выиграли золотую медаль.

SELECT
    e.event_id,
    e.name AS event_name,
    COUNT(r.player_id) AS gold_medalists_count
FROM
    events e
JOIN
    results r ON e.event_id = r.event_id
WHERE
    e.is_team_event = 0
    AND r.medal = 'GOLD'
GROUP BY
    e.event_id, e.name
HAVING
    COUNT(r.player_id) > 1;

-- 3. Найдите всех игроков, которые выиграли хотя бы одну медаль (GOLD, SILVER и BRONZE) на одной Олимпиаде.
--    Результат: (player-name, olympic-id).

SELECT
    DISTINCT p.name AS player_name,
    o.olympic_id
FROM
    players p
JOIN
    results r ON p.player_id = r.player_id
JOIN
    events e ON r.event_id = e.event_id
JOIN
    olympics o ON e.olympic_id = o.olympic_id
WHERE
    r.medal IN ('GOLD', 'SILVER', 'BRONZE');

-- 4. В какой стране был наибольший процент игроков (из перечисленных в наборе данных),
--    чьи имена начинались с гласной?

WITH players_by_country AS (
    SELECT
        c.country_id,
        COUNT(p.player_id) AS total_players,
        COUNT(CASE
                WHEN LEFT(p.name, 1) ILIKE ANY (ARRAY['A', 'E', 'I', 'O', 'U'])
                THEN 1
              END) AS vowel_players
    FROM
        countries c
    JOIN
        players p ON c.country_id = p.country_id
    GROUP BY
        c.country_id
)
SELECT
    c.name AS country_name,
    (CAST(vowel_players AS FLOAT) / total_players) * 100 AS vowel_start_percentage
FROM
    players_by_country pc
JOIN
    countries c ON pc.country_id = c.country_id
ORDER BY
    vowel_start_percentage DESC
LIMIT 1;

-- 5. Для Олимпийских игр 2000 года найдите 5 стран с минимальным соотношением количества групповых медалей к численности населения.

WITH team_medals AS (
    SELECT
        c.country_id,
        COUNT(r.medal) AS team_medal_count
    FROM
        countries c
    JOIN
        players p ON c.country_id = p.country_id
    JOIN
        results r ON p.player_id = r.player_id
    JOIN
        events e ON r.event_id = e.event_id
    JOIN
        olympics o ON e.olympic_id = o.olympic_id
    WHERE
        o.year = 2000
        AND e.is_team_event = 1
    GROUP BY
        c.country_id
)
SELECT
    c.name AS country_name,
    COALESCE((team_medal_count::FLOAT / NULLIF(c.population, 0)), 0) AS team_medal_to_population_ratio
FROM
    team_medals tm
JOIN
    countries c ON tm.country_id = c.country_id
ORDER BY
    team_medal_to_population_ratio
LIMIT 5;
