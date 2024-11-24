CREATE TABLE StagingCommune ( WKT TEXT, ID TEXT, OBJETO TEXT, COMUNAS VARCHAR(100), BARRIOS VARCHAR(100), PERIMETRO FLOAT, AREA FLOAT );

COPY StagingCommune FROM '/csvfiles/comunas.csv' DELIMITER ';' CSV HEADER;

INSERT INTO Commune (CommuneKey, Perimeter)
SELECT CAST(SPLIT_PART(ID, '.', 1) AS INT) AS CommuneKey, ST_GeomFromText(WKT, 4326) AS Perimeter
FROM StagingCommune;

DROP TABLE StagingCommune;

CREATE TEMP TABLE temp_neighbourhood (
    WKT TEXT,
    BARRIO TEXT,
    COMUNA TEXT,
    PERIMETRO NUMERIC,
    AREA NUMERIC,
    OBJETO TEXT
);

COPY temp_neighbourhood FROM '/csvfiles/barrios.csv' DELIMITER ';' CSV HEADER;

INSERT INTO Neighbourhood (Perimeter, CommuneKey, Name)
SELECT ST_GeomFromText(WKT, 4326), 
       CAST(TRIM(TRAILING '.00000000000' FROM COMUNA) AS INTEGER),
       BARRIO
FROM temp_neighbourhood;

DROP TABLE temp_neighbourhood;

CREATE TABLE temp_users (
    ID_usuario TEXT,
    genero_usuario VARCHAR(10),
    edad_usuario TEXT,
    fecha_alta DATE,
    hora_alta TIME,
    Customer_Has_Dni VARCHAR(10)
);

COPY temp_users FROM '/csvfiles/usuarios_2023.csv' DELIMITER ',' CSV HEADER;

INSERT INTO DateTime (Date, Seconds, Minutes, Hours, Day, Month, Year)
SELECT DISTINCT 
       fecha_alta + hora_alta, 
       EXTRACT(SECOND FROM hora_alta), 
       EXTRACT(MINUTE FROM hora_alta), 
       EXTRACT(HOUR FROM hora_alta), 
       EXTRACT(DAY FROM fecha_alta), 
       EXTRACT(MONTH FROM fecha_alta), 
       EXTRACT(YEAR FROM fecha_alta)
FROM temp_users
ON CONFLICT (Date) DO NOTHING;

INSERT INTO Users (Sex, Age, RegistrationDate)
SELECT genero_usuario, 
       CAST(translate(edad_usuario, ',', '.') AS DECIMAL), 
       fecha_alta + hora_alta
FROM temp_users
WHERE edad_usuario ~ '^[0-9,]+$' 
  AND translate(edad_usuario, ',', '.')::DECIMAL BETWEEN 1 AND 120;

DROP TABLE temp_users; 

CREATE TEMP TABLE temp_bicicleteros (
    long DECIMAL,
    lat DECIMAL,
    id INT,
    nombre VARCHAR(255),
    anio_de_in INT,
    tipo VARCHAR(50),
    cantidad VARCHAR(50),
    ubicacion VARCHAR(255),
    clasificac VARCHAR(50),
    calle VARCHAR(255),
    altura VARCHAR(50),
    calle2 VARCHAR(255),
    barrio VARCHAR(255),
    comuna VARCHAR(50),
    codigo_postal VARCHAR(10),
    codigo_postal_argentino VARCHAR(10)
);

COPY temp_bicicleteros FROM '/csvfiles/bicicleteros.csv' DELIMITER ',' CSV HEADER NULL AS 'None';

INSERT INTO Coordinates (Location, NeighbourhoodKey)
SELECT ST_SetSRID(ST_MakePoint(long, lat), 4326), NeighbourhoodKey
FROM temp_bicicleteros
JOIN Neighbourhood ON UPPER(temp_bicicleteros.barrio) = UPPER(Neighbourhood.Name)
ON CONFLICT (Location) DO NOTHING;

INSERT INTO Stations (Capacity, Name, Type, NormalizedAddress, CoordinateKey)
SELECT NULLIF(cantidad, '')::INT, nombre, clasificac, calle || ' ' || COALESCE(NULLIF(altura, ''), ''), Coordinates.CoordinateKey
FROM temp_bicicleteros
JOIN Coordinates ON ST_SetSRID(ST_MakePoint(temp_bicicleteros.long, temp_bicicleteros.lat), 4326) = Coordinates.Location;

DROP TABLE temp_bicicleteros; 

CREATE TEMP TABLE temp_trips (
    dummy_column VARCHAR(255), 
    trip_id VARCHAR(255),
    duration VARCHAR(255),  
    start_time TIMESTAMP,
    start_station_id VARCHAR(255),
    start_station_name VARCHAR(255),
    start_station_address VARCHAR(255),
    start_station_long DECIMAL,
    start_station_lat DECIMAL,
    end_time TIMESTAMP,
    end_station_id VARCHAR(255),
    end_station_name VARCHAR(255),
    end_station_address VARCHAR(255),
    end_station_long DECIMAL,
    end_station_lat DECIMAL,
    user_id VARCHAR(255),
    bike_model VARCHAR(255),
    user_gender VARCHAR(10)
);

COPY temp_trips FROM '/csvfiles/trips_2023.csv' DELIMITER ',' CSV HEADER NULL AS 'NA';

CREATE TEMP TABLE temp_timestamps AS
SELECT DISTINCT start_time AS timestamp
FROM temp_trips
UNION                                                     
SELECT DISTINCT end_time AS timestamp
FROM temp_trips;                                                                              
               
INSERT INTO DateTime (Date, Seconds, Minutes, Hours, Day, Month, Year)
SELECT 
    timestamp AS Date,                                                                       
    EXTRACT(SECOND FROM timestamp) AS Seconds,
    EXTRACT(MINUTE FROM timestamp) AS Minutes,
    EXTRACT(HOUR FROM timestamp) AS Hours,
    EXTRACT(DAY FROM timestamp) AS Day,
    EXTRACT(MONTH FROM timestamp) AS Month,
    EXTRACT(YEAR FROM timestamp) AS Year
FROM temp_timestamps
ON CONFLICT DO NOTHING;

INSERT INTO BicycleTrips (UserKey, StartStation, EndStation, StartDate, EndDate)
SELECT
    CAST(REGEXP_REPLACE(temp_trips.user_id, '[^0-9]', '', 'g') AS INT) AS UserKey,         
    ss.StationKey,                                                                          
    es.StationKey,                                                                         
    temp_trips.start_time,                                                                 
    temp_trips.end_time
FROM                   
    temp_trips
JOIN
    Users u ON CAST(REGEXP_REPLACE(temp_trips.user_id, '[^0-9]', '', 'g') AS INT) = u.UserKey
JOIN          
    Stations ss ON upper(TRIM(SPLIT_PART(temp_trips.start_station_name, '-', 2))) = upper(ss.Name)
JOIN                                                                                   
    Stations es ON upper(TRIM(SPLIT_PART(temp_trips.end_station_name, '-', 2))) = upper(es.Name)  
ON CONFLICT (UserKey, StartStation, EndStation, StartDate, EndDate) DO NOTHING;


DROP TABLE temp_timestamps; 
DROP TABLE temp_trips; 
