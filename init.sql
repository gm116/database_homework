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
VALUES ('United States', 'US'),
       ('Canada', 'CA'),
       ('Mexico', 'MX');

INSERT INTO City (Name, Region)
VALUES ('New York', 'New York'),
       ('Los Angeles', 'California'),
       ('Toronto', 'Ontario'),
       ('Vancouver', 'British Columbia'),
       ('Mexico City', 'Mexico City');

INSERT INTO Station (Name, CityName, Region)
VALUES ('Grand Central', 'New York', 'New York'),
       ('Union Station', 'Los Angeles', 'California'),
       ('Union Station', 'Toronto', 'Ontario'),
       ('Pacific Central', 'Vancouver', 'British Columbia'),
       ('Tacubaya', 'Mexico City', 'Mexico City');

INSERT INTO Train (TrainNr, TrainType, Capacity)
VALUES (101, 'Express', 300),
       (102, 'Local', 150),
       (103, 'Intercity', 200);

INSERT INTO Connection (FromStation, ToStation, TrainNr, Departure, Arrival, CityNameFrom, CityNameTo, RegionFrom,
                        RegionTo)
VALUES ('Grand Central', 'Union Station', 101, '2024-10-08 08:00:00', '2024-10-08 11:00:00', 'New York', 'Los Angeles',
        'New York', 'California'),
       ('Union Station', 'Pacific Central', 102, '2024-10-08 09:00:00', '2024-10-08 12:00:00', 'Los Angeles',
        'Vancouver', 'California', 'British Columbia'),
       ('Union Station', 'Tacubaya', 103, '2024-10-08 10:00:00', '2024-10-08 12:30:00', 'Toronto', 'Mexico City',
        'Ontario', 'Mexico City');
