## Задание 3 by Fadeev Daniil

1. Создайте таблицу с большим количеством данных:
    ```sql
    CREATE TABLE test_cluster AS 
    SELECT 
        generate_series(1,1000000) as id,
        CASE WHEN random() < 0.5 THEN 'A' ELSE 'B' END as category,
        md5(random()::text) as data;
    ```

2. Создайте индекс:
    ```sql
    CREATE INDEX test_cluster_cat_idx ON test_cluster(category);
    ```

3. Измерьте производительность до кластеризации:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM test_cluster WHERE category = 'A';
    ```
    
    *План выполнения:*
    `Bitmap Heap Scan on test_cluster  (cost=5623.98..20310.47 rows=504200 width=39) (actual time=19.988..106.046 rows=500120 loops=1)
   Recheck Cond: (category = 'A'::text)
   Heap Blocks: exact=8334
   ->  Bitmap Index Scan on test_cluster_cat_idx  (cost=0.00..5497.93 rows=504200 width=0) (actual time=18.294..18.319 rows=500120 loops=1)
   Index Cond: (category = 'A'::text)
   Planning Time: 1.833 ms
   Execution Time: 120.578 ms
   `
    
    *Объясните результат:*
    `используется индекс, но из за бльшого количества блоков и данных все равно долго запрос обрабатывается`

4. Выполните кластеризацию:
    ```sql
    CLUSTER test_cluster USING test_cluster_cat_idx;
    ```
    
    *Результат:*
    `workshop.public> CLUSTER test_cluster USING test_cluster_cat_idx
   [2024-12-04 20:03:50] completed in 680 ms`

5. Измерьте производительность после кластеризации:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM test_cluster WHERE category = 'A';
    ```
    
    *План выполнения:*
    `Bitmap Heap Scan on test_cluster  (cost=5623.98..20260.47 rows=504200 width=39) (actual time=18.139..110.607 rows=500120 loops=1)
   Recheck Cond: (category = 'A'::text)
   Heap Blocks: exact=4168
   ->  Bitmap Index Scan on test_cluster_cat_idx  (cost=0.00..5497.93 rows=504200 width=0) (actual time=17.425..17.430 rows=500120 loops=1)
   Index Cond: (category = 'A'::text)
   Planning Time: 2.537 ms
   Execution Time: 124.735 ms
   `
    
    *Объясните результат:*
    `блоков стало меньше, но лучше и быстрее не стало`

6. Сравните производительность до и после кластеризации:
    
    *Сравнение:*
    `производительность не улучшилась возможно из за того что данные распределены по разным блокам
     и нужно обрабатывать большое количество строк`