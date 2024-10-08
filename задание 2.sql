-- а) Запрос на нахождение всех прямых рейсов из Москвы в Тверь
SELECT *
FROM Connection
WHERE FromStation = 'Москва' AND ToStation = 'Тверь';

-- б) Запрос на нахождение всех многосегментных маршрутов с однодневным трансфером из Москвы в Санкт-Петербург
SELECT c1.FromStation, c1.ToStation, c1.TrainNr, c1.Departure, c1.Arrival
FROM Connection c1
         JOIN Connection c2 ON c1.ToStation = c2.FromStation
WHERE c1.FromStation = 'Москва'
  AND c2.ToStation = 'Санкт-Петербург'
  AND EXTRACT(DAY FROM c1.Departure) = EXTRACT(DAY FROM c2.Arrival)
  AND EXTRACT(MONTH FROM c1.Departure) = EXTRACT(MONTH FROM c2.Arrival)
  AND EXTRACT(YEAR FROM c1.Departure) = EXTRACT(YEAR FROM c2.Arrival);
