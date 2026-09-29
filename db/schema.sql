-- Register livestock: legacy database schema.
-- Fictional service for the Joint Keepers demo. The structure changes only through db/migrations; the modernisation stage must leave it untouched.

CREATE TABLE Keeper (
    KeeperId    INTEGER PRIMARY KEY,
    Name        TEXT NOT NULL,
    Address     TEXT NOT NULL,
    Phone       TEXT
);

CREATE TABLE Holding (
    HoldingId       INTEGER PRIMARY KEY,
    HoldingNumber   TEXT NOT NULL UNIQUE,
    Name            TEXT NOT NULL,
    Address         TEXT NOT NULL
);

CREATE TABLE Animal (
    AnimalId    INTEGER PRIMARY KEY,
    TagNumber   TEXT NOT NULL UNIQUE,
    Species     TEXT NOT NULL,
    DateOfBirth TEXT NOT NULL,
    HoldingId   INTEGER NOT NULL REFERENCES Holding(HoldingId),
    KeeperId    INTEGER NOT NULL REFERENCES Keeper(KeeperId)
);

CREATE TABLE Movement (
    MovementId      INTEGER PRIMARY KEY,
    AnimalId        INTEGER NOT NULL REFERENCES Animal(AnimalId),
    FromHoldingId   INTEGER NOT NULL REFERENCES Holding(HoldingId),
    ToHoldingId     INTEGER NOT NULL REFERENCES Holding(HoldingId),
    MovementDate    TEXT NOT NULL
);
