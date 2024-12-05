## Задание 2 by Fadeev Daniil

1. Удалите старую базу данных, если есть:
    ```shell
    docker compose down
    ```

2. Поднимите базу данных из src/docker-compose.yml:
    ```shell
    docker compose down && docker compose up -d
    ```

3. Обновите статистику:
    ```sql
    ANALYZE t_books;
    ```

4. Создайте полнотекстовый индекс:
    ```sql
    CREATE INDEX t_books_fts_idx ON t_books 
    USING GIN (to_tsvector('english', title));
    ```

5. Найдите книги, содержащие слово 'expert':
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books 
    WHERE to_tsvector('english', title) @@ to_tsquery('english', 'expert');
    ```
    
    *План выполнения:*
    `Bitmap Heap Scan on t_books  (cost=21.03..1336.08 rows=750 width=33) (actual time=0.088..0.089 rows=1 loops=1)
   "  Recheck Cond: (to_tsvector('english'::regconfig, (title)::text) @@ '''expert'''::tsquery)"
   Heap Blocks: exact=1
   ->  Bitmap Index Scan on t_books_fts_idx  (cost=0.00..20.84 rows=750 width=0) (actual time=0.072..0.072 rows=1 loops=1)
   "        Index Cond: (to_tsvector('english'::regconfig, (title)::text) @@ '''expert'''::tsquery)"
   Planning Time: 1.018 ms
   Execution Time: 0.175 ms
   `
    
    *Объясните результат:*
    `Запрос использует Bitmap Index Scan для поиска в полнотекстовом индексе GIN, затем проверяет соответствие
     через Recheck Cond, и извлекает данные из таблицы с точным совпадением, что позволяет быстро найти книги с словом ‘expert`

6. Удалите индекс:
    ```sql
    DROP INDEX t_books_fts_idx;
    ```

7. Создайте таблицу lookup:
    ```sql
    CREATE TABLE t_lookup (
         item_key VARCHAR(10) NOT NULL,
         item_value VARCHAR(100)
    );
    ```

8. Добавьте первичный ключ:
    ```sql
    ALTER TABLE t_lookup 
    ADD CONSTRAINT t_lookup_pk PRIMARY KEY (item_key);
    ```

9. Заполните данными:
    ```sql
    INSERT INTO t_lookup 
    SELECT 
         LPAD(CAST(generate_series(1, 150000) AS TEXT), 10, '0'),
         'Value_' || generate_series(1, 150000);
    ```

10. Создайте кластеризованную таблицу:
     ```sql
     CREATE TABLE t_lookup_clustered (
          item_key VARCHAR(10) PRIMARY KEY,
          item_value VARCHAR(100)
     );
     ```

11. Заполните её теми же данными:
     ```sql
     INSERT INTO t_lookup_clustered 
     SELECT * FROM t_lookup;
     
     CLUSTER t_lookup_clustered USING t_lookup_clustered_pkey;
     ```

12. Обновите статистику:
     ```sql
     ANALYZE t_lookup;
     ANALYZE t_lookup_clustered;
     ```

13. Выполните поиск по ключу в обычной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup WHERE item_key = '0000000455';
     ```
     
     *План выполнения:*
     `Index Scan using t_lookup_pk on t_lookup  (cost=0.42..8.44 rows=1 width=23) (actual time=0.114..0.121 rows=1 loops=1)
    Index Cond: ((item_key)::text = '0000000455'::text)
    Planning Time: 0.859 ms
    Execution Time: 0.205 ms
    `
     
     *Объясните результат:*
     `запрос использует индекс для быстрого поиска строки по ключу в обычной таблице, что позволяет выполнить операцию с минимальными затратами времени`

14. Выполните поиск по ключу в кластеризованной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup_clustered WHERE item_key = '0000000455';
     ```
     
     *План выполнения:*
     `Index Scan using t_lookup_clustered_pkey on t_lookup_clustered  (cost=0.42..8.44 rows=1 width=23) (actual time=0.392..0.398 rows=1 loops=1)
    Index Cond: ((item_key)::text = '0000000455'::text)
    Planning Time: 0.924 ms
    Execution Time: 0.474 ms`
     
     *Объясните результат:*
     `В кластеризованной таблице данные хранятся в порядке индекса, что позволяет ускорить поиск, но выполнение запроса 
      занимает немного больше времени из-за обработки кластеризованной структуры`

15. Создайте индекс по значению для обычной таблицы:
     ```sql
     CREATE INDEX t_lookup_value_idx ON t_lookup(item_value);
     ```

16. Создайте индекс по значению для кластеризованной таблицы:
     ```sql
     CREATE INDEX t_lookup_clustered_value_idx 
     ON t_lookup_clustered(item_value);
     ```

17. Выполните поиск по значению в обычной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup WHERE item_value = 'T_BOOKS';
     ```
     
     *План выполнения:*
     `Index Scan using t_lookup_value_idx on t_lookup  (cost=0.42..8.44 rows=1 width=23) (actual time=0.282..0.286 rows=0 loops=1)
    Index Cond: ((item_value)::text = 'T_BOOKS'::text)
    Planning Time: 1.313 ms
    Execution Time: 0.354 ms
    `
     
     *Объясните результат:*
     `запрос использует индекс по значению, что ускоряет поиск однако в данном случае 
      результатом поиска является отсутствие строк что видно из времени выполнения`

18. Выполните поиск по значению в кластеризованной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup_clustered WHERE item_value = 'T_BOOKS';
     ```
     
     *План выполнения:*
     `Index Scan using t_lookup_clustered_value_idx on t_lookup_clustered  (cost=0.42..8.44 rows=1 width=23) (actual time=0.207..0.213 rows=0 loops=1)
    Index Cond: ((item_value)::text = 'T_BOOKS'::text)
    Planning Time: 1.266 ms
    Execution Time: 0.304 ms
    `
     
     *Объясните результат:*
     `поиск использует индекс на поле item_value, но не находит совпадений что также подтверждается временем выполнения запроса`

19. Сравните производительность поиска по значению в обычной и кластеризованной таблицах:
     
     *Сравнение:*
     `производительность поиска в кластеризованной таблице может быть немного выше, так как данные в таблице упорядочены
      по ключу. но так как оба индекса находятся на одном и том же поле, 
      разница в реальном времени выполнения поиска может быть незначительной, если поиск 
      не затруднён большим количеством данных или частыми обновлениями.`