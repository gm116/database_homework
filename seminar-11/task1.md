# Задание 1: BRIN индексы и bitmap-сканирование

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

4. Создайте BRIN индекс по колонке category:
   ```sql
   CREATE INDEX t_books_brin_cat_idx ON t_books USING brin(category);
   ```

5. Найдите книги с NULL значением category:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE category IS NULL;
   ```

   *План выполнения:*
   `   Index Scan using t_books_cat_null_idx on t_books  (cost=0.13..27.50 rows=5 width=33) (actual time=0.042..0.049 rows=1
   loops=1)
   Planning Time: 4.168 ms
   Execution Time: 0.147 ms`

*Объясните результат:*
`тут запрос использует индексное сканирование по индексу t_books_cat_null_idx, который создан для строк, где category is
null. благодаря этому сканированию запрос выполняется быстрее, чем при последовательном обходе всей таблицы`

6. Создайте BRIN индекс по автору:
   ```sql
   CREATE INDEX t_books_brin_author_idx ON t_books USING brin(author);
   ```

7. Выполните поиск по категории и автору:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books 
   WHERE category = 'INDEX' AND author = 'SYSTEM';
   ```

   *План выполнения:*
   Bitmap Heap Scan on t_books  (cost=12.00..16.02 rows=1 width=33) (actual time=23.663..23.664 rows=0 loops=1)
   Recheck Cond: ((category)::text = 'INDEX'::text)
   Rows Removed by Index Recheck: 150000
   Filter: ((author)::text = 'SYSTEM'::text)
   Heap Blocks: lossy=1225
   ->  Bitmap Index Scan on t_books_brin_cat_idx  (cost=0.00..12.00 rows=1 width=0) (actual time=0.056..0.057 rows=12250 loops=1)
   Index Cond: ((category)::text = 'INDEX'::text)
   Planning Time: 0.339 ms
   Execution Time: 23.720 ms
   `

   *Объясните результат:*
   `в данном запросе используется Bitmap Heap Scan, который сначала ищет записи по индексу t_books_brin_cat_idx для категории ‘INDEX’.
    затем происходит фильтрация по автору ‘SYSTEM’, и только после этого из таблицы извлекаются нужные строки.`


8. Получите список уникальных категорий:
   ```sql
   EXPLAIN ANALYZE
   SELECT DISTINCT category 
   FROM t_books 
   ORDER BY category;
   ```

   *План выполнения:*
   `Sort  (cost=3100.15..3100.16 rows=5 width=7) (actual time=36.620..36.628 rows=7 loops=1)
   Sort Key: category
   Sort Method: quicksort  Memory: 25kB
   ->  HashAggregate  (cost=3100.04..3100.09 rows=5 width=7) (actual time=36.519..36.528 rows=7 loops=1)
   Group Key: category
   Batches: 1  Memory Usage: 24kB
   ->  Seq Scan on t_books  (cost=0.00..2725.03 rows=150003 width=7) (actual time=0.121..9.921 rows=150003 loops=1)
   Planning Time: 0.656 ms
   Execution Time: 36.854 ms
   `

   *Объясните результат:*
   `используется последовательное сканирование таблицы t_books для получения всех записей,
    так как нужно просмотреть каждую строку, чтобы собрать уникальные категории`

9. Подсчитайте книги, где автор начинается на 'S':
   ```sql
   EXPLAIN ANALYZE
   SELECT COUNT(*) 
   FROM t_books 
   WHERE author LIKE 'S%';
   ```

   *План выполнения:*
   `Planning Time: 0.128 ms
   Execution Time: 17.400 ms
   Aggregate  (cost=3100.08..3100.09 rows=1 width=8) (actual time=17.370..17.371 rows=1 loops=1)
   ->  Seq Scan on t_books  (cost=0.00..3100.04 rows=15 width=0) (actual time=17.365..17.366 rows=0 loops=1)
   Rows Removed by Filter: 150003
   Filter: ((author)::text ~~ 'S%'::text)
   `

   *Объясните результат:*
   `использовалось последовательное сканирование, так как для условия LIKE 'S%' стандартные индексы малоэффективны.
    фильтрация по автору убрала 150003 строк, так как все записи проверяются на совпадение с паттерном.
    выполнение заняло 17.4 мс, так как сканируется вся таблица, а найденных строк оказалось 0.`

10. Создайте индекс для регистронезависимого поиска:
    ```sql
    CREATE INDEX t_books_lower_title_idx ON t_books(LOWER(title));
    ```

11. Подсчитайте книги, начинающиеся на 'O':
    ```sql
    EXPLAIN ANALYZE
    SELECT COUNT(*) 
    FROM t_books 
    WHERE LOWER(title) LIKE 'o%';
    ```

   *План выполнения:*
   `Aggregate  (cost=3476.92..3476.93 rows=1 width=8) (actual time=66.033..66.042 rows=1 loops=1)
   ->  Seq Scan on t_books  (cost=0.00..3475.05 rows=750 width=0) (actual time=66.025..66.036 rows=1 loops=1)
   Filter: (lower((title)::text) ~~ 'o%'::text)
   Rows Removed by Filter: 150002
   Planning Time: 2.323 ms
   Execution Time: 66.212 ms
   `

   *Объясните результат:*
   `индексы не использовались.
   это произошло потому что использование функции LOWER в фильтре требует полного сканирования таблицы для сопоставления префикса`

12. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_brin_cat_idx;
    DROP INDEX t_books_brin_author_idx;
    DROP INDEX t_books_lower_title_idx;
    ```

13. Создайте составной BRIN индекс:
    ```sql
    CREATE INDEX t_books_brin_cat_auth_idx ON t_books 
    USING brin(category, author);
    ```

14. Повторите запрос из шага 7:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books 
    WHERE category = 'INDEX' AND author = 'SYSTEM';
    ```

   *План выполнения:*
   `Bitmap Heap Scan on t_books  (cost=5.54..428.26 rows=1 width=33) (actual time=0.090..0.103 rows=0 loops=1)
   Recheck Cond: ((author)::text = 'SYSTEM'::text)
   Filter: ((category)::text = 'INDEX'::text)
   ->  Bitmap Index Scan on t_books_author_title_index  (cost=0.00..5.54 rows=149 width=0) (actual time=0.088..0.100 rows=0 loops=1)
   Index Cond: ((author)::text = 'SYSTEM'::text)
   Planning Time: 1.626 ms
   Execution Time: 0.195 ms
   `
   
   *Объясните результат:*
   тут я заметил что у меня затерялся старый индекс. Я еще раз пересоздал бдшку и brin индекс все равное не используется

   `Seq Scan on t_books  (cost=0.00..3475.00 rows=4 width=519) (actual time=20.075..20.076 rows=0 loops=1)
   Filter: (((category)::text = 'INDEX'::text) AND ((author)::text = 'SYSTEM'::text))
   Rows Removed by Filter: 150000
   Planning Time: 0.491 ms
   Execution Time: 20.127 ms
   `