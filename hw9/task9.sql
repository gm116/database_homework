-- 1
SELECT (bit_length(name) + char_length(race)) AS calculation
FROM demographics;

-- 2
SELECT id, bit_length(name) AS name, birthday, bit_length(race) AS race
FROM demographics;

-- 3
SELECT id, ascii(left(name, 1)) AS name, birthday, ascii(left(race, 1)) AS race
FROM demographics;

-- 4
SELECT concat_ws(' ', prefix, first, last, suffix) AS title
FROM names;

-- 5
SELECT md5 || repeat('1', char_length(sha256) - char_length(md5))   AS md5,
       repeat('0', char_length(sha256) - char_length(sha1)) || sha1 AS sha1,
       sha256
FROM encryption;

-- 6
SELECT left(project, commits) AS project, right(address, contributors) AS address
FROM repositories;

-- 7
SELECT project, commits, contributors, regexp_replace(address, '\d', '!', 'g') AS address
FROM repositories;

-- 8
SELECT name, weight, price, ROUND(price / (weight / 1000), 2) AS price_per_kg
FROM products
ORDER BY price_per_kg ASC, name ASC;
