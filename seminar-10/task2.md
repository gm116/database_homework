# Задание 2: Специальные случаи использования индексов

# Партиционирование и специальные случаи использования индексов

1. Удалите прошлый инстанс PostgreSQL - `docker-compose down` в папке `src` и запустите новый: `docker-compose up -d`.

2. Создайте партиционированную таблицу и заполните её данными:

    ```sql
    -- Создание партиционированной таблицы
    CREATE TABLE t_books_part (
        book_id     INTEGER      NOT NULL,
        title       VARCHAR(100) NOT NULL,
        category    VARCHAR(30),
        author      VARCHAR(100) NOT NULL,
        is_active   BOOLEAN      NOT NULL
    ) PARTITION BY RANGE (book_id);

    -- Создание партиций
    CREATE TABLE t_books_part_1 PARTITION OF t_books_part
        FOR VALUES FROM (MINVALUE) TO (50000);

    CREATE TABLE t_books_part_2 PARTITION OF t_books_part
        FOR VALUES FROM (50000) TO (100000);

    CREATE TABLE t_books_part_3 PARTITION OF t_books_part
        FOR VALUES FROM (100000) TO (MAXVALUE);

    -- Копирование данных из t_books
    INSERT INTO t_books_part 
    SELECT * FROM t_books;
    ```

3. Обновите статистику таблиц:
   ```sql
   ANALYZE t_books;
   ANALYZE t_books_part;
   ```


4. Выполните запрос для поиска книги с id = 18:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part WHERE book_id = 18;
   ```

   *План выполнения:*
   Seq Scan on t_books_part_1 t_books_part  (cost=0.00..1032.99 rows=1 width=32) (actual time=0.107..21.554 rows=1
   loops=1)
   Filter: (book_id = 18)
   Rows Removed by Filter: 49998
   Planning Time: 5.215 ms
   Execution Time: 21.679 ms

   *Объясните результат:*
   без индекса не очень быстро работает запрос. И партиционирование не супер круче на данном примере. Ну как бы да,
   отфильтровали в 3 раза меньше строк, но можно улучшить, добавив индексы

5. Выполните поиск по названию книги:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part 
   WHERE title = 'Expert PostgreSQL Architecture';
   ```

   *План выполнения:*
   Append  (cost=0.00..3101.01 rows=3 width=33) (actual time=72.790..263.177 rows=1 loops=1)
   ->  Seq Scan on t_books_part_1  (cost=0.00..1032.99 rows=1 width=32) (actual time=72.790..72.790 rows=1 loops=1)
   Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   Rows Removed by Filter: 49998
   ->  Seq Scan on t_books_part_2  (cost=0.00..1034.00 rows=1 width=33) (actual time=39.783..39.783 rows=0 loops=1)
   Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   Rows Removed by Filter: 50000
   ->  Seq Scan on t_books_part_3  (cost=0.00..1034.01 rows=1 width=34) (actual time=150.599..150.599 rows=0 loops=1)
   Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   Rows Removed by Filter: 50001
   Planning Time: 6.274 ms
   Execution Time: 263.227 ms

*Объясните результат:*
использовались все партиции таблицы. не использовалась оптимизация в виде индекса. долгое исполнение

6. Создайте партиционированный индекс:
   ```sql
   CREATE INDEX ON t_books_part(title);
   ```

   *Результат:*
   создал

7. Повторите запрос из шага 5:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part 
   WHERE title = 'Expert PostgreSQL Architecture';
   ```

   *План выполнения:*
   Append  (cost=0.29..24.94 rows=3 width=33) (actual time=0.331..1.210 rows=1 loops=1)
   ->  Index Scan using t_books_part_1_title_idx on t_books_part_1  (cost=0.29..8.31 rows=1 width=32) (actual
   time=0.330..0.332 rows=1 loops=1)
   Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   ->  Index Scan using t_books_part_2_title_idx on t_books_part_2  (cost=0.29..8.31 rows=1 width=33) (actual
   time=0.202..0.202 rows=0 loops=1)
   Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   ->  Index Scan using t_books_part_3_title_idx on t_books_part_3  (cost=0.29..8.31 rows=1 width=34) (actual
   time=0.664..0.664 rows=0 loops=1)
   Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
   Planning Time: 3.296 ms
   Execution Time: 1.465 ms

*Объясните результат:*
результат на лицо. Сразу видно ускорение поиска из за добавленного индекса

8. Удалите созданный индекс:
   ```sql
   DROP INDEX t_books_part_title_idx;
   ```

   *Результат:*
   удалил

9. Создайте индекс для каждой партиции:
   ```sql
   CREATE INDEX ON t_books_part_1(title);
   CREATE INDEX ON t_books_part_2(title);
   CREATE INDEX ON t_books_part_3(title);
   ```

   *Результат:*
   создал

10. Повторите запрос из шага 5:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books_part 
    WHERE title = 'Expert PostgreSQL Architecture';
    ```

    *План выполнения:*
    Append  (cost=0.29..24.94 rows=3 width=33) (actual time=0.220..0.500 rows=1 loops=1)
    ->  Index Scan using t_books_part_1_title_idx on t_books_part_1  (cost=0.29..8.31 rows=1 width=32) (actual
    time=0.220..0.220 rows=1 loops=1)
    Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
    ->  Index Scan using t_books_part_2_title_idx on t_books_part_2  (cost=0.29..8.31 rows=1 width=33) (actual
    time=0.109..0.109 rows=0 loops=1)
    Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
    ->  Index Scan using t_books_part_3_title_idx on t_books_part_3  (cost=0.29..8.31 rows=1 width=34) (actual
    time=0.159..0.159 rows=0 loops=1)
    Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text)
    Planning Time: 2.675 ms
    Execution Time: 0.641 ms

    *Объясните результат:*
    стало еще быстрее, чем имея обобщенный индекс на все партиции


11. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_part_1_title_idx;
    DROP INDEX t_books_part_2_title_idx;
    DROP INDEX t_books_part_3_title_idx;
    ```

    *Результат:*
    удалил

12. Создайте обычный индекс по book_id:
    ```sql
    CREATE INDEX t_books_part_idx ON t_books_part(book_id);
    ```

    *Результат:*
    создал

13. Выполните поиск по book_id:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books_part WHERE book_id = 11011;
    ```

    *План выполнения:*
    Index Scan using t_books_part_1_book_id_idx on t_books_part_1 t_books_part  (cost=0.29..8.31 rows=1 width=32) (
    actual time=0.104..0.112 rows=1 loops=1)
    Index Cond: (book_id = 11011)
    Planning Time: 2.285 ms
    Execution Time: 0.247 ms

    *Объясните результат:*
    нашел нужную строку быстро, используя индекс

14. Создайте индекс по полю is_active:
    ```sql
    CREATE INDEX t_books_active_idx ON t_books(is_active);
    ```

    *Результат:*
    создал

15. Выполните поиск активных книг с отключенным последовательным сканированием:
    ```sql
    SET enable_seqscan = off;
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE is_active = true;
    SET enable_seqscan = on;
    ```

    *План выполнения:*
    Index Cond: (is_active = true)
    ->  Bitmap Index Scan on t_books_active_idx  (cost=0.00..818.89 rows=74480 width=0) (actual time=5.899..5.908
    rows=74969 loops=1)
    Heap Blocks: exact=1225
    Recheck Cond: is_active
    Bitmap Heap Scan on t_books  (cost=837.51..2807.32 rows=74480 width=33) (actual time=6.103..43.728 rows=74969
    loops=1)
    Execution Time: 46.942 ms

    *Объясните результат:*
    не используя последовательное сканирование ищем данные сначала с помощью Bitmap Index Scan, а потом Bitmap Heap Scan
    извлекает данные из таблицы

16. Создайте составной индекс:
    ```sql
    CREATE INDEX t_books_author_title_index ON t_books(author, title);
    ```

    *Результат:*
    создал

17. Найдите максимальное название для каждого автора:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, MAX(title) 
    FROM t_books 
    GROUP BY author;
    ```

    *План выполнения:*
    HashAggregate  (cost=3475.00..3485.00 rows=1000 width=42) (actual time=85.352..85.458 rows=1003 loops=1)
    Group Key: author
    Batches: 1 Memory Usage: 193kB
    ->  Seq Scan on t_books  (cost=0.00..2725.00 rows=150000 width=21) (actual time=0.099..25.743 rows=150000 loops=1)
    Planning Time: 0.960 ms
    Execution Time: 86.170 ms

    *Объясните результат:*
    HashAggregate — используется для группировки по автору и нахождения максимального названия книги

    запрос работает медленно из-за последовательного сканирования. Почему то не работает индекс. Возможно он
    неэффективен или у меня что то сломалось

18. Выберите первых 10 авторов:
    ```sql
    EXPLAIN ANALYZE
    SELECT DISTINCT author 
    FROM t_books 
    ORDER BY author 
    LIMIT 10;
    ```

    *План выполнения:*
    Limit  (cost=0.42..56.67 rows=10 width=10) (actual time=1.219..1.948 rows=10 loops=1)
    ->  Result  (cost=0.42..5625.42 rows=1000 width=10) (actual time=1.218..1.946 rows=10 loops=1)
    ->  Unique  (cost=0.42..5625.42 rows=1000 width=10) (actual time=1.217..1.942 rows=10 loops=1)
    ->  Index Only Scan using t_books_author_title_index on t_books  (cost=0.42..5250.42 rows=150000 width=10) (actual
    time=1.215..1.867 rows=1359 loops=1)
    Heap Fetches: 3
    Planning Time: 0.973 ms
    Execution Time: 2.177 ms

    *Объясните результат:*
    тут уже применяется индекс и ускоряет поиск, но пришлось 3 раза взять строки из основной таблицы

19. Выполните поиск и сортировку:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE author LIKE 'T%'
    ORDER BY author, title;
    ```

    *План выполнения:*
    Sort  (cost=3100.29..3100.33 rows=15 width=21) (actual time=22.875..22.883 rows=1 loops=1)
    "  Sort Key: author, title"
    Sort Method: quicksort Memory: 25kB
    ->  Seq Scan on t_books  (cost=0.00..3100.00 rows=15 width=21) (actual time=22.772..22.779 rows=1 loops=1)
    Filter: ((author)::text ~~ 'T%'::text)
    Rows Removed by Filter: 149999
    Planning Time: 2.136 ms
    Execution Time: 22.959 ms

    *Объясните результат:*
    не применяя индекс используем быструю сортировку

20. Добавьте новую книгу:
    ```sql
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150001, 'Cookbook', 'Mr. Hide', NULL, true);
    COMMIT;
    ```

    *Результат:*
    добавил!

21. Создайте индекс по категории:
    ```sql
    CREATE INDEX t_books_cat_idx ON t_books(category);
    ```

    *Результат:*
    создал

22. Найдите книги без категории:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE category IS NULL;
    ```

    *План выполнения:*
    Index Scan using t_books_cat_idx on t_books  (cost=0.29..8.14 rows=1 width=21) (actual time=0.156..0.183 rows=1
    loops=1)
    Index Cond: (category IS NULL)
    Planning Time: 1.258 ms
    Execution Time: 0.273 ms

    *Объясните результат:*
    быстро нашли книгу без категории

23. Создайте частичные индексы:
    ```sql
    DROP INDEX t_books_cat_idx;
    CREATE INDEX t_books_cat_null_idx ON t_books(category) WHERE category IS NULL;
    ```

    *Результат:*
    готово

24. Повторите запрос из шага 22:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE category IS NULL;
    ```

    *План выполнения:*
    Index Scan using t_books_cat_null_idx on t_books  (cost=0.12..7.97 rows=1 width=21) (actual time=0.074..0.081 rows=1
    loops=1)
    Planning Time: 1.226 ms
    Execution Time: 0.173 ms

    *Объясните результат:*
    получилось быстрее и теперь использовался индекс, который был создан только для строк, где category = NULL

25. Создайте частичный уникальный индекс:
    ```sql
    CREATE UNIQUE INDEX t_books_selective_unique_idx 
    ON t_books(title) 
    WHERE category = 'Science';
    
    -- Протестируйте его
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150002, 'Unique Science Book', 'Author 1', 'Science', true);
    
    -- Попробуйте вставить дубликат
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150003, 'Unique Science Book', 'Author 2', 'Science', true);
    
    -- Но можно вставить такое же название для другой категории
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150004, 'Unique Science Book', 'Author 3', 'History', true);
    ```

    *Результат:*
    [2024-11-27 20:06:55] [23505] ERROR: duplicate key value violates unique constraint "t_books_selective_unique_idx"
    [2024-11-27 20:06:55] Подробности: Key (title)=(Unique Science Book) already exists.

    workshop.public> INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150004, 'Unique Science Book', 'Author 3', 'History', true)
    [2024-11-27 20:07:15] 1 row affected in 15 ms

    *Объясните результат:*
    первый запрос успешно вставляется
    второй вставить нельзя тк индекс запрещает дубли в одной категории
    третий запрос вставляется, тк категория уже другая