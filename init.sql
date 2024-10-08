CREATE TABLE Country
(
    Name VARCHAR(100) PRIMARY KEY,
    Code VARCHAR(10) NOT NULL
);

CREATE TABLE City
(
    Name   VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    PRIMARY KEY (Name, Region)
);

CREATE TABLE Station
(
    Name     VARCHAR(100),
    CityName VARCHAR(100),
    Region   VARCHAR(100),
    PRIMARY KEY (Name, CityName, Region)
);

CREATE TABLE Train
(
    TrainNr   INT PRIMARY KEY,
    TrainType VARCHAR(100),
    Capacity  INT
);

CREATE TABLE Connection
(
    FromStation  VARCHAR(100),
    ToStation    VARCHAR(100),
    TrainNr      INT,
    Departure    TIMESTAMP,
    Arrival      TIMESTAMP,
    CityNameFrom VARCHAR(100),
    CityNameTo   VARCHAR(100),
    RegionFrom   VARCHAR(100),
    RegionTo     VARCHAR(100),
    PRIMARY KEY (FromStation, ToStation, TrainNr, Departure),
    FOREIGN KEY (FromStation, CityNameFrom, RegionFrom) REFERENCES Station (Name, CityName, Region),
    FOREIGN KEY (ToStation, CityNameTo, RegionTo) REFERENCES Station (Name, CityName, Region),
    FOREIGN KEY (TrainNr) REFERENCES Train (TrainNr)
);

INSERT INTO Country (Name, Code)
VALUES ('Россия', 'RU');

INSERT INTO City (Name, Region)
VALUES ('Москва', 'Москва'),
       ('Санкт-Петербург', 'Санкт-Петербург'),
       ('Тверь', 'Тверская область');

INSERT INTO Station (Name, CityName, Region)
VALUES ('Москва', 'Москва', 'Москва'),
       ('Санкт-Петербург', 'Санкт-Петербург', 'Санкт-Петербург'),
       ('Тверь', 'Тверь', 'Тверская область');

INSERT INTO Train (TrainNr, TrainType, Capacity)
VALUES (101, 'Экспресс', 300),
       (102, 'Региональный', 150),
       (103, 'Междугородний', 200);

INSERT INTO Connection (FromStation, ToStation, TrainNr, Departure, Arrival, CityNameFrom, CityNameTo, RegionFrom,
                        RegionTo)
VALUES
    ('Москва', 'Тверь', 101, '2024-10-08 08:00:00', '2024-10-08 09:30:00', 'Москва', 'Тверь',
     'Москва', 'Тверская область'),
    ('Тверь', 'Санкт-Петербург', 101, '2024-10-08 10:00:00', '2024-10-08 12:00:00', 'Тверь', 'Санкт-Петербург',
     'Тверская область', 'Санкт-Петербург'),
    ('Москва', 'Санкт-Петербург', 102, '2024-10-08 08:00:00', '2024-10-08 12:00:00', 'Москва', 'Санкт-Петербург',
     'Москва', 'Санкт-Петербург');
