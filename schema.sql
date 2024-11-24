CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

CREATE TABLE DateTime (
    Date TIMESTAMP PRIMARY KEY,
    Seconds INT NOT NULL,
    Minutes INT NOT NULL,
    Hours INT NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL
);

CREATE TABLE Commune (
    CommuneKey INT PRIMARY KEY,
    Perimeter GEOMETRY(MultiPolygon, 4326)
);


CREATE TABLE Neighbourhood (
    NeighbourhoodKey SERIAL PRIMARY KEY,
    Perimeter GEOMETRY(MultiPolygon, 4326),
    CommuneKey INT,
    Name VARCHAR(100),
    FOREIGN KEY (CommuneKey) REFERENCES Commune(CommuneKey)
);


CREATE TABLE Coordinates (
    CoordinateKey SERIAL PRIMARY KEY,
    Location GEOGRAPHY(Point, 4326) UNIQUE NOT NULL,
    NeighbourhoodKey INT,
    FOREIGN KEY (NeighbourhoodKey) REFERENCES Neighbourhood(NeighbourhoodKey)
);

CREATE TABLE Stations (
    StationKey SERIAL PRIMARY KEY,
    Capacity INT,
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    NormalizedAddress VARCHAR(255) NOT NULL,
    CoordinateKey INT NOT NULL,
    FOREIGN KEY (CoordinateKey) REFERENCES Coordinates(CoordinateKey)
);

CREATE TABLE Users (
    UserKey SERIAL PRIMARY KEY,
    Sex VARCHAR(10) NOT NULL,
    Age INT NOT NULL,
    RegistrationDate TIMESTAMP NOT NULL,
    FOREIGN KEY (RegistrationDate) REFERENCES DateTime(Date)
);

CREATE TABLE BicycleTrips (
    TripKey SERIAL PRIMARY KEY,
    UserKey INT NOT NULL,
    StartStation INT NOT NULL,
    EndStation INT NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NOT NULL,
    FOREIGN KEY (UserKey) REFERENCES Users(UserKey),
    FOREIGN KEY (StartStation) REFERENCES Stations(StationKey),
    FOREIGN KEY (EndStation) REFERENCES Stations(StationKey),
    FOREIGN KEY (StartDate) REFERENCES DateTime(Date),
    FOREIGN KEY (EndDate) REFERENCES DateTime(Date),
    CONSTRAINT unique_trip UNIQUE (UserKey, StartStation, EndStation, StartDate, EndDate)
);
