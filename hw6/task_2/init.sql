CREATE TABLE Publisher (
                           PubName VARCHAR(255) PRIMARY KEY,
                           PubAddress VARCHAR(255) NOT NULL
);

CREATE TABLE Book (
                      isbn     VARCHAR(13) PRIMARY KEY,
                      Title    VARCHAR(255) NOT NULL,
                      Author   VARCHAR(255) NOT NULL,
                      PagesNum INT          NOT NULL,
                      PubYear  INT          NOT NULL,
                      PubName  VARCHAR(255),
                      FOREIGN KEY (PubName) REFERENCES Publisher (PubName)
);

CREATE TABLE Reader (
                        number SERIAL PRIMARY KEY,
                        LastName VARCHAR(100) NOT NULL,
                        FirstName VARCHAR(100) NOT NULL,
                        Address VARCHAR(255) NOT NULL,
                        BirthDate DATE NOT NULL
);

CREATE TABLE Category (
                          CategoryName VARCHAR(255) PRIMARY KEY,
                          ParentCat VARCHAR(255),
                          FOREIGN KEY (ParentCat) REFERENCES Category(CategoryName)
);

CREATE TABLE Copy (
                      ISBN VARCHAR(13),
                      CopyNumber INT,
                      ShelfPosition VARCHAR(100),
                      PRIMARY KEY (ISBN, CopyNumber),
                      FOREIGN KEY (ISBN) REFERENCES Book(isbn)
);

CREATE TABLE Borrow (
                        ReaderNumber INT,
                        ISBN VARCHAR(13),
                        CopyNumber INT,
                        BorrowDate DATE NOT NULL,
                        ReturnDate DATE NOT NULL,
                        PRIMARY KEY (ReaderNumber, ISBN, CopyNumber),
                        FOREIGN KEY (ReaderNumber) REFERENCES Reader(number),
                        FOREIGN KEY (ISBN, CopyNumber) REFERENCES Copy(ISBN, CopyNumber)
);

-- Заполняем издательства
INSERT INTO Publisher (PubName, PubAddress)
VALUES
    ('Penguin Books', 'New York, USA'),
    ('HarperCollins', 'London, UK'),
    ('Vintage', 'Toronto, Canada'),
    ('Random House', 'New York, USA');

INSERT INTO Book (isbn, Title, Author, PagesNum, PubYear, PubName)
VALUES
    ('9781234567897', 'Adventures of Huckleberry Finn', 'Mark Twain', 366, 1884, 'Vintage'),
    ('9782345678901', 'The Prince and the Pauper', 'Mark Twain', 320, 1881, 'HarperCollins'),
    ('9783456789012', 'Tom Sawyer', 'Mark Twain', 274, 1876, 'Penguin Books'),
    ('9781234567898', 'A Connecticut Yankee in King Arthurs Court', 'Mark Twain', 451, 1889, 'Vintage'),
    ('9781234567899', 'The Innocents Abroad', 'Mark Twain', 372, 1869, 'HarperCollins'),
    ('9781234567900', 'The Innocents Abroaddddd', 'Mark Twain', 372, 1869, 'HarperCollins'),
    ('9784567890123', 'War and Peace', 'Leo Tolstoy', 1225, 1869, 'Random House'),
    ('9785678901234', 'Anna Karenina', 'Leo Tolstoy', 864, 1878, 'Penguin Books'),
    ('9785678901235', 'Annnnnnnnna Karenina', 'Leo Tolstoy', 864, 1878, 'Penguin Books'),
    ('9785678901236', 'Annaaaaaaaaa Karenina', 'Leo Tolstoy', 864, 1878, 'Penguin Books'),
    ('9785678901237', 'Annaaaaa Karenina', 'Leo Tolstoy', 864, 1878, 'Penguin Books'),
    ('9786789012345', 'Moby Dick', 'Herman Melville', 585, 1851, 'HarperCollins'),
    ('9787890123456', 'Pride and Prejudice', 'Jane Austen', 432, 1813, 'Vintage'),
    ('9788901234567', 'Emma', 'Jane Austen', 474, 1815, 'Vintage'),
    ('9789012345678', 'Sense and Sensibility', 'Jane Austen', 409, 1811, 'Penguin Books'),
    ('9780123456789', 'Great Expectations', 'Charles Dickens', 505, 1861, 'Random House');

-- Заполняем экземпляры книг
INSERT INTO Copy (ISBN, CopyNumber, ShelfPosition)
VALUES
    ('9781234567897', 1, 'Shelf A1'),
    ('9782345678901', 1, 'Shelf A2'),
    ('9783456789012', 1, 'Shelf A3'),
    ('9784567890123', 1, 'Shelf B1'),
    ('9785678901234', 1, 'Shelf B2'),
    ('9786789012345', 1, 'Shelf C1'),
    ('9787890123456', 1, 'Shelf C2'),
    ('9788901234567', 1, 'Shelf D1'),
    ('9789012345678', 1, 'Shelf D2'),
    ('9780123456789', 1, 'Shelf E1'),
    ('9781234567897', 2, 'Shelf A1'),
    ('9782345678901', 2, 'Shelf A2'),
    ('9781234567898', 1, 'Shelf A2'),
    ('9781234567899', 1, 'Shelf A2'),
    ('9781234567900', 1, 'Shelf A2');

-- Заполняем читателей
INSERT INTO Reader (number, LastName, FirstName, Address, BirthDate)
VALUES
    (1, 'Smith', 'John', '123 Main St', '1985-03-15'),
    (2, 'Johnson', 'Emily', '456 Oak Ave', '1992-07-22'),
    (3, 'Brown', 'Michael', '789 Pine Rd', '1978-11-11');

-- Заполняем бронирования
INSERT INTO Borrow (ReaderNumber, ISBN, CopyNumber, BorrowDate, ReturnDate)
VALUES
    (1, '9781234567897', 1, '2024-10-01', '2024-10-15'),
    (1, '9782345678901', 1, '2024-10-01', '2024-10-15'),
    (1, '9783456789012', 1, '2024-10-01', '2024-10-15'),
    (1, '9781234567898', 1, '2024-10-01', '2024-10-15'),
    (1, '9781234567899', 1, '2024-10-01', '2024-10-15'),
    (1, '9781234567900', 1, '2024-10-01', '2024-10-15'),
    (2, '9783456789012', 1, '2024-10-02', '2024-10-16'),
    (2, '9784567890123', 1, '2024-10-03', '2024-10-17'),
    (3, '9785678901234', 1, '2024-10-04', '2024-10-18'),
    (3, '9786789012345', 1, '2024-10-05', '2024-10-19');

-- Заполняем категории и подкатегории
INSERT INTO Category (CategoryName, ParentCat)
VALUES
    ('Literature', NULL),
    ('Classics', 'Literature'),
    ('Sport', NULL),
    ('Football', 'Sport'),
    ('Basketball', 'Sport'),
    ('Running', 'Sport');
