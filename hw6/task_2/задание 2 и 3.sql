INSERT INTO Reader (number, LastName, FirstName, Address, BirthDate)
VALUES ( (SELECT COALESCE(MAX(number), 0) + 1 FROM Reader),
        'Петров', 'Василий', 'Some Address', '1990-01-01');

INSERT INTO Publisher (PubName, PubAddress)
VALUES ('test publisher', 'ул. Ленина, 1, Москва');

INSERT INTO Book (isbn, Title, Author, PagesNum, PubYear, PubName)
VALUES ('123456', 'test book', 'test author', 200, 2023, 'test publisher');

INSERT INTO Copy (ISBN, CopyNumber, ShelfPosition)
VALUES ('123456', 4, 'A1-001');


INSERT INTO Borrow (ReaderNumber, ISBN, CopyNumber, BorrowDate, ReturnDate)
VALUES (
           (SELECT number FROM Reader WHERE LastName = 'Петров' AND FirstName = 'Василий'),
           '123456',
           4,
           CURRENT_DATE,
           '2024-10-19'
       );

----------------------------------------
-- Шаг 1: Удалить бронирования для копий книг, опубликованных после 2000 года
DELETE FROM Borrow
WHERE (ISBN, CopyNumber) IN (
    SELECT c.ISBN, c.CopyNumber
    FROM Copy c
             JOIN Book b ON c.ISBN = b.ISBN
    WHERE b.PubYear > 2000
);

-- Шаг 2: Удалить копии книг
DELETE FROM Copy
WHERE ISBN IN (
    SELECT isbn
    FROM Book
    WHERE PubYear > 2000
);

-- Шаг 3: Удалить книги, опубликованные после 2000 года
DELETE FROM Book
WHERE PubYear > 2000;

-- Готово!!!!!!!!!
-------------------------------------------------

--- SQL запросы
/*

1й запрос возвращает всех студентов, у которых нет оценок выше или равных 4.0

2й запрос возвращает всех профессоров с общей суммой кредитов по их лекциям и, так же,
всех профессоров, у которых нет лекций (для них сумма кредитов равна нулю)

3й запрос возвращает студентов, у которых наивысшая оценка выше или равна 4

*/