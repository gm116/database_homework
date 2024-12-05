# Задание 1. B-tree индексы в PostgreSQL

1. Запустите БД через docker compose в ./src/docker-compose.yml:

2. Выполните запрос для поиска книги с названием 'Oracle Core' и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE title = 'Oracle Core';
   ```

   *План выполнения:*
   Seq Scan on t_books  (cost=0.00..3100.00 rows=1 width=33) (actual time=26.174..26.175 rows=1 loops=1)
   Filter: ((title)::text = 'Oracle Core'::text)
   Rows Removed by Filter: 149999
   Planning Time: 3.004 ms
   Execution Time: 26.211 ms

*Объясните результат:*
видим что без индексов так себе по времени находит

3. Создайте B-tree индексы:
   ```sql
   CREATE INDEX t_books_title_idx ON t_books(title);
   CREATE INDEX t_books_active_idx ON t_books(is_active);
   ```

   *Результат:*
   создал индексы

4. Проверьте информацию о созданных индексах:
   ```sql
   SELECT schemaname, tablename, indexname, indexdef
   FROM pg_catalog.pg_indexes
   WHERE tablename = 't_books';
   ```

   *Результат:*
   public,t_books,t_books_id_pk,CREATE UNIQUE INDEX t_books_id_pk ON public.t_books USING btree (book_id)
   public,t_books,t_books_title_idx,CREATE INDEX t_books_title_idx ON public.t_books USING btree (title)
   public,t_books,t_books_active_idx,CREATE INDEX t_books_active_idx ON public.t_books USING btree (is_active)

*Объясните результат:*
все созданные индексы активны

5. Обновите статистику таблицы:
   ```sql
   ANALYZE t_books;
   ```

   *Результат:*
   обновил

6. Выполните запрос для поиска книги 'Oracle Core' и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE title = 'Oracle Core';
   ```

   *План выполнения:*
   Index Scan using t_books_title_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.358..0.359 rows=1
   loops=1)
   Index Cond: ((title)::text = 'Oracle Core'::text)
   Planning Time: 1.915 ms
   Execution Time: 0.444 ms

*Объясните результат:*
видим улучшение по времени поиска, тк были применены индексы

7. Выполните запрос для поиска книги по book_id и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE book_id = 18;
   ```

   *План выполнения:*
   Index Scan using t_books_id_pk on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.573..0.574 rows=1
   loops=1)
   Index Cond: (book_id = 18)
   Planning Time: 0.776 ms
   Execution Time: 0.674 ms

*Объясните результат:*
так же видим планируемое время и время выполнения близким друг к другу и быстрым

8. Выполните запрос для поиска активных книг и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE is_active = true;
   ```

   *План выполнения:*
   Seq Scan on t_books  (cost=0.00..2725.00 rows=75055 width=33) (actual time=0.053..22.729 rows=75024 loops=1)
   Filter: is_active
   Rows Removed by Filter: 74976
   Planning Time: 0.667 ms
   Execution Time: 34.982 ms

*Объясните результат:*
тут напротив видим что индексы не очень работают на bool

9. Посчитайте количество строк и уникальных значений:
   ```sql
   SELECT 
       COUNT(*) as total_rows,
       COUNT(DISTINCT title) as unique_titles,
       COUNT(DISTINCT category) as unique_categories,
       COUNT(DISTINCT author) as unique_authors
   FROM t_books;
   ```

   *Результат:*
   150000,150000,6,1003


10. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_title_idx;
    DROP INDEX t_books_active_idx;
    ```

    *Результат:*
    удалил индексы

11. Основываясь на предыдущих результатах, создайте индексы для оптимизации следующих запросов:
    a. `WHERE title = $1 AND category = $2`
    b. `WHERE title = $1`
    c. `WHERE category = $1 AND author = $2`
    d. `WHERE author = $1 AND book_id = $2`

    *Созданные индексы:*
    ```sql
    CREATE INDEX t_books_title_category_idx ON t_books(title, category);
    CREATE INDEX t_books_title_idx ON t_books(title);
    CREATE INDEX t_books_category_author_idx ON t_books(category, author);
    CREATE INDEX t_books_author_bookid_idx ON t_books(author, book_id);
    ```

    *Объясните ваше решение:*
    Создан индекс на title и category, чтобы ускорить запросы по этим колонкам вместе.
    Создан индекс на title, чтобы ускорить запросы по названию.
    Создан индекс на category и author, чтобы ускорить запросы по этим колонкам вместе.
    Создан индекс на author и book_id, чтобы ускорить запросы по автору и ID.

12. Протестируйте созданные индексы.

    *Результаты тестов:*
    1)
    ```sql
    EXPLAIN ANALYZE SELECT * FROM t_books WHERE title = 'Oracle Core' AND category = 'History';
    ```

    Index Scan using t_books_title_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.194..0.201 rows=0
    loops=1)
    Index Cond: ((title)::text = 'Oracle Core'::text)
    Filter: ((category)::text = 'History'::text)
    Rows Removed by Filter: 1
    Planning Time: 0.486 ms
    Execution Time: 0.319 ms

    *Объясните результаты:*
    индекс работает и быстрее идет поиск

    2)
    ```sql
    EXPLAIN ANALYZE SELECT * FROM t_books WHERE title = 'Oracle Core';
    ```
    Index Scan using t_books_title_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.327..0.339 rows=1
    loops=1)
    Index Cond: ((title)::text = 'Oracle Core'::text)
    Planning Time: 0.621 ms
    Execution Time: 0.455 ms

    *Объясните результаты:*
    тут тоже все хорошо

    3)
    ```sql
    EXPLAIN ANALYZE SELECT * FROM t_books WHERE category = 'Test' AND author = 'TEST';
    ```

    Index Scan using t_books_category_author_idx on t_books  (cost=0.29..8.31 rows=1 width=33) (actual time=1.261..1.268
    rows=0 loops=1)
    Index Cond: (((category)::text = 'Test'::text) AND ((author)::text = 'TEST'::text))
    Planning Time: 0.486 ms
    Execution Time: 1.352 ms

    *Объясните результаты:*
    использование индекса значительно ускорило проверку условий

    4)
    ```sql
    EXPLAIN ANALYZE SELECT * FROM t_books WHERE author = 'TEST' AND book_id = 600;
    ```

    Index Scan using t_books_author_bookid_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=1.807..1.814
    rows=0 loops=1)
    Index Cond: (((author)::text = 'TEST'::text) AND (book_id = 600))
    Planning Time: 1.085 ms
    Execution Time: 2.445 ms

    *Объясните результаты:*
    индекс использвуется эффективно по двум условиям

13. Выполните регистронезависимый поиск по началу названия:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE 'Relational%';
    ```

    *План выполнения:*
    Seq Scan on t_books  (cost=0.00..3100.00 rows=15 width=33) (actual time=100.563..100.568 rows=0 loops=1)
    Filter: ((title)::text ~~* 'Relational%'::text)
    Rows Removed by Filter: 150000
    Planning Time: 6.134 ms
    Execution Time: 100.630 ms

    *Объясните результат:*
    долгое время выполнения связано с полным сканированием таблицы из-за отсутствия индекса, который может в
    регистронезависимый поиск

14. Создайте функциональный индекс:
    ```sql
    CREATE INDEX t_books_up_title_idx ON t_books(UPPER(title));
    ```

    *Результат:*
    сделал!

15. Выполните запрос из шага 13 с использованием UPPER:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE UPPER(title) LIKE 'RELATIONAL%';
    ```

    *План выполнения:*
    Seq Scan on t_books  (cost=0.00..3475.00 rows=750 width=33) (actual time=53.687..53.693 rows=0 loops=1)
    Filter: (upper((title)::text) ~~ 'RELATIONAL%'::text)
    Rows Removed by Filter: 150000
    Planning Time: 1.759 ms
    Execution Time: 53.772 ms

    *Объясните результат:*
    стало лучше, но кажется можно еще лучше

16. Выполните поиск подстроки:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE '%Core%';
    ```

    *План выполнения:*
    Seq Scan on t_books  (cost=0.00..3100.00 rows=15 width=33) (actual time=74.335..74.342 rows=1 loops=1)
    Filter: ((title)::text ~~* '%Core%'::text)
    Rows Removed by Filter: 149999
    Planning Time: 0.946 ms
    Execution Time: 74.446 ms

    *Объясните результат:*
    запрос медленный из-за полного сканирования таблицы

17. Попробуйте удалить все индексы:
    ```sql
    DO $$ 
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT indexname FROM pg_indexes 
                  WHERE tablename = 't_books' 
                  AND indexname != 'books_pkey')
        LOOP
            EXECUTE 'DROP INDEX ' || r.indexname;
        END LOOP;
    END $$;
    ```

    *Результат:*
    удалил


18. Создайте индекс для оптимизации суффиксного поиска:
    ```sql
    -- Вариант 1: с reverse()
    CREATE INDEX t_books_rev_title_idx ON t_books(reverse(title));
    
    -- Вариант 2: с триграммами
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
    CREATE INDEX t_books_trgm_idx ON t_books USING gin (title gin_trgm_ops);
    ```

    *Результаты тестов:*

    первый:

    Seq Scan on t_books  (cost=0.00..3099.00 rows=1200 width=519) (actual time=94.844..94.853 rows=1 loops=1)
    Filter: ((title)::text ~~* '%Core%'::text)
    Rows Removed by Filter: 149999
    Planning Time: 1.929 ms
    Execution Time: 94.919 ms

    второй:

    Bitmap Heap Scan on t_books  (cost=21.57..76.78 rows=15 width=33) (actual time=0.091..0.096 rows=1 loops=1)
    Recheck Cond: ((title)::text ~~* '%Core%'::text)
    Heap Blocks: exact=1
    ->  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..21.56 rows=15 width=0) (actual time=0.058..0.062 rows=1
    loops=1)
    Index Cond: ((title)::text ~~* '%Core%'::text)
    Planning Time: 2.354 ms
    Execution Time: 0.248 ms

    *Объясните результаты:*
    во втором случае не используется последовательное сканирование и сокращается число проверяемых блоков
    так же уменьшилась стоимость и работает быстрее

19. Выполните поиск по точному совпадению:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title = 'Oracle Core';
    ```

    *План выполнения:*
    Bitmap Heap Scan on t_books  (cost=116.57..120.58 rows=1 width=33) (actual time=0.191..0.201 rows=1 loops=1)
    Recheck Cond: ((title)::text = 'Oracle Core'::text)
    Heap Blocks: exact=1
    ->  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..116.57 rows=1 width=0) (actual time=0.141..0.151 rows=1
    loops=1)
    Index Cond: ((title)::text = 'Oracle Core'::text)
    Planning Time: 0.777 ms
    Execution Time: 0.328 ms

    *Объясните результат:*
    используем Bitmap Heap Scan как раньше, эффективно и быстро происходит поиск с точным совпадением

20. Выполните поиск по началу названия:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE 'Relational%';
    ```

    *План выполнения:*
    Bitmap Heap Scan on t_books  (cost=95.15..150.36 rows=15 width=33) (actual time=0.218..0.226 rows=0 loops=1)
    Recheck Cond: ((title)::text ~~* 'Relational%'::text)
    Rows Removed by Index Recheck: 1
    Heap Blocks: exact=1
    ->  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..95.15 rows=15 width=0) (actual time=0.138..0.145 rows=1
    loops=1)
    Index Cond: ((title)::text ~~* 'Relational%'::text)
    Planning Time: 0.897 ms
    Execution Time: 0.352 ms

    *Объясните результат:*
    даже при использовании ILIKE значительно сокращается время выполнения по сравнению с последовательным сканированием

21. Создайте свой пример индекса с обратной сортировкой:
    ```sql
    CREATE INDEX t_books_desc_idx ON t_books(title DESC);
    ```

    *Тестовый запрос:*
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title = 'Oracle Core';

    ```

    *План выполнения:*
    Index Scan using t_books_desc_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.332..0.339 rows=1
    loops=1)
    Index Cond: ((title)::text = 'Oracle Core'::text)
    Planning Time: 1.859 ms
    Execution Time: 0.413 ms

    *Объясните результат:*
    индекс с обратной сортировкой работает даже для точных совпадений и ускоряет запрос, даже если сортировка в индексе
    не совпадает с запросом.