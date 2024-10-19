-- 1. Показать все названия книг вместе с именами издателей
SELECT Title, PubName
FROM Book;

-- 2. В какой книге наибольшее количество страниц
SELECT Title, PagesNum
FROM Book
ORDER BY PagesNum DESC
LIMIT 1;

-- 3. Какие авторы написали более 5 книг
SELECT Author
FROM Book
GROUP BY Author
HAVING COUNT(DISTINCT isbn) > 5;


-- 4. В каких книгах более чем в два раза больше страниц, чем среднее количество страниц для всех книг
SELECT Title, PagesNum
FROM Book
WHERE PagesNum > (SELECT AVG(PagesNum) * 2 FROM Book);

-- 5. Какие категории содержат подкатегории
SELECT DISTINCT c1.CategoryName
FROM Category c1
         JOIN Category c2 ON c1.CategoryName = c2.ParentCat;

-- 6. У какого автора написано максимальное количество книг
SELECT Author, COUNT(isbn) AS BookCount
FROM Book
GROUP BY Author
ORDER BY BookCount DESC
LIMIT 1;

-- 7. Какие читатели забронировали все книги, написанные "Марком Твеном"
SELECT DISTINCT r.LastName, r.FirstName
FROM Reader r
         JOIN Borrow b ON r.number = b.ReaderNumber
         JOIN Book k ON b.ISBN = k.isbn
WHERE k.Author = 'Mark Twain'
GROUP BY r.number
HAVING COUNT(DISTINCT k.isbn) = (SELECT COUNT(*) FROM Book WHERE Author = 'Mark Twain');

-- 8. Какие книги имеют более одной копии
SELECT Title, COUNT(CopyNumber) AS CopyCount
FROM Book b
         JOIN Copy c ON b.isbn = c.ISBN
GROUP BY Title
HAVING COUNT(CopyNumber) > 1;

-- 9. ТОП 10 самых старых книг
SELECT Title, PubYear
FROM Book
ORDER BY PubYear
LIMIT 10;

-- 10. Перечислите все категории в категории “Спорт” (с любым уровнем вложенности)
WITH RECURSIVE Subcategories AS (
    SELECT CategoryName
    FROM Category
    WHERE CategoryName = 'Sport'
    UNION ALL
    SELECT c.CategoryName
    FROM Category c
             JOIN Subcategories sc ON c.ParentCat = sc.CategoryName
)
SELECT CategoryName
FROM Subcategories;
