CREATE TABLE Reader
(
    ID        SERIAL PRIMARY KEY,
    LastName  VARCHAR(100) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    Address   VARCHAR(255),
    BirthDate DATE
);

CREATE TABLE Publisher
(
    PubName    VARCHAR(255) PRIMARY KEY,
    PubAddress VARCHAR(255)
);

CREATE TABLE Book
(
    ISBN     CHAR(13) PRIMARY KEY,
    Title    VARCHAR(255) NOT NULL,
    Author   VARCHAR(255) NOT NULL,
    PagesNum INT,
    PubYear  INT,
    PubName  VARCHAR(255) NOT NULL,
    FOREIGN KEY (PubName) REFERENCES Publisher (PubName)
);


CREATE TABLE Category
(
    CategoryName VARCHAR(100) PRIMARY KEY,
    ParentCat    VARCHAR(100),
    FOREIGN KEY (ParentCat) REFERENCES Category (CategoryName)
);

CREATE TABLE BookCopy
(
    ISBN          CHAR(13),
    CopyNumber    INT,
    ShelfPosition VARCHAR(100),
    PRIMARY KEY (ISBN, CopyNumber),
    FOREIGN KEY (ISBN) REFERENCES Book (ISBN)
);

CREATE TABLE Borrowing
(
    ReaderNr   INT,
    ISBN       CHAR(13),
    CopyNumber INT,
    ReturnDate DATE,
    PRIMARY KEY (ReaderNr, ISBN, CopyNumber),
    FOREIGN KEY (ReaderNr) REFERENCES Reader (ID),
    FOREIGN KEY (ISBN, CopyNumber) REFERENCES BookCopy (ISBN, CopyNumber)
);


CREATE TABLE BookCat
(
    ISBN         CHAR(13),
    CategoryName VARCHAR(100),
    PRIMARY KEY (ISBN, CategoryName),
    FOREIGN KEY (ISBN) REFERENCES Book (ISBN),
    FOREIGN KEY (CategoryName) REFERENCES Category (CategoryName)
);


--------------------------------------------------------------------
-- Заполним данные

-- Данные для таблицы Reader
INSERT INTO Reader (LastName, FirstName, Address, BirthDate)
VALUES ('Иванов', 'Иван', 'Москва', '1985-06-15'),
       ('Петров', 'Петр', 'Москва', '1990-04-21'),
       ('Сидоров', 'Сидор', 'Санкт-Петербург', '1978-11-30'),
       ('Андреев', 'Андрей', 'Москва', '1995-03-10');

-- Данные для таблицы Publisher
INSERT INTO Publisher (PubName, PubAddress)
VALUES ('Эксмо', 'Москва'),
       ('АСТ', 'Москва'),
       ('Питер', 'Санкт-Петербург');

-- Данные для таблицы Book
INSERT INTO Book (ISBN, Title, Author, PagesNum, PubYear, PubName)
VALUES ('9781234567897', 'Путешествие на горы', 'Автор 1', 300, 2015, 'Эксмо'),
       ('9781234567898', 'Путеводитель по горам', 'Автор 2', 350, 2016, 'АСТ'),
       ('9781234567899', 'Горы и приключения', 'Автор 3', 400, 2017, 'Питер'),
       ('9781234567900', 'Жизнь в горах', 'Автор 4', 280, 2018, 'Эксмо'),
       ('9781234567901', 'Путешествия по миру', 'Автор 5', 500, 2019, 'АСТ');

-- Данные для таблицы Category
INSERT INTO Category (CategoryName, ParentCat)
VALUES ('Горы', NULL),
       ('Путешествия', NULL);

-- Данные для таблицы BookCopy
INSERT INTO BookCopy (ISBN, CopyNumber, ShelfPosition)
VALUES ('9781234567897', 1, 'A1'),
       ('9781234567898', 1, 'A2'),
       ('9781234567899', 1, 'A3'),
       ('9781234567900', 1, 'A4'),
       ('9781234567901', 1, 'A5');

-- Данные для таблицы Borrowing
INSERT INTO Borrowing (ReaderNr, ISBN, CopyNumber, ReturnDate)
VALUES (1, '9781234567897', 1, '2024-10-01'),
       (1, '9781234567899', 1, '2024-10-01'),
       (2, '9781234567898', 1, NULL),
       (3, '9781234567900', 1, '2024-10-05'),
       (4, '9781234567901', 1, NULL);

-- Данные для таблицы BookCat
INSERT INTO BookCat (ISBN, CategoryName)
VALUES ('9781234567897', 'Горы'),
       ('9781234567898', 'Горы'),
       ('9781234567899', 'Горы'),
       ('9781234567900', 'Горы'),
       ('9781234567901', 'Путешествия');
