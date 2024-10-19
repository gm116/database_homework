-- а) Какие фамилии читателей в Москве?
SELECT LastName
FROM Reader
WHERE Address = 'Москва';

-- б) Какие книги (author, title) брал Иван Иванов?
SELECT Book.Author, Book.Title
FROM Borrowing
         JOIN Reader ON Borrowing.ReaderNr = Reader.ID
         JOIN Book ON Borrowing.ISBN = Book.ISBN
WHERE Reader.LastName = 'Иванов' AND Reader.FirstName = 'Иван';

-- в) Какие книги (ISBN) из категории "Горы" не относятся к категории "Путешествия"?
SELECT bc.ISBN
FROM BookCat bc
         JOIN Category c ON bc.CategoryName = c.CategoryName
WHERE c.CategoryName = 'Горы'
  AND bc.ISBN NOT IN (
    SELECT bc2.ISBN
    FROM BookCat bc2
    WHERE bc2.CategoryName = 'Путешествия'
);

-- г) Какие читатели (LastName, FirstName) вернули копию книги?
SELECT Reader.LastName, Reader.FirstName
FROM Borrowing
         JOIN Reader ON Borrowing.ReaderNr = Reader.ID
WHERE Borrowing.ReturnDate IS NOT NULL;

-- д) Какие читатели (LastName, FirstName) брали хотя бы одну книгу (не копию), которую брал также Иван Иванов (не включайте Ивана Иванова в результат)?

SELECT DISTINCT r.LastName, r.FirstName
FROM Borrowing b
         JOIN Reader r ON b.ReaderNr = r.ID
WHERE b.ISBN IN (
    SELECT b2.ISBN
    FROM Borrowing b2
             JOIN Reader r2 ON b2.ReaderNr = r2.ID
    WHERE r2.LastName = 'Иванов' AND r2.FirstName = 'Иван'
)
  AND r.LastName <> 'Иванов' AND r.FirstName <> 'Иван';
