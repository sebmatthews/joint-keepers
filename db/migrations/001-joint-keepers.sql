PRAGMA foreign_keys = OFF;

CREATE TABLE AnimalKeeper (
    AnimalId    INTEGER NOT NULL REFERENCES Animal(AnimalId),
    KeeperId    INTEGER NOT NULL REFERENCES Keeper(KeeperId),
    IsPrimary   INTEGER NOT NULL CHECK (IsPrimary IN (0, 1)),
    DateAdded   TEXT NOT NULL,
    PRIMARY KEY (AnimalId, KeeperId)
);

INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded)
SELECT AnimalId, KeeperId, 1, '2026-10-01'
FROM Animal;

CREATE TABLE Animal_New (
    AnimalId    INTEGER PRIMARY KEY,
    TagNumber   TEXT NOT NULL UNIQUE,
    Species     TEXT NOT NULL,
    DateOfBirth TEXT NOT NULL,
    HoldingId   INTEGER NOT NULL REFERENCES Holding(HoldingId)
);

INSERT INTO Animal_New (AnimalId, TagNumber, Species, DateOfBirth, HoldingId)
SELECT AnimalId, TagNumber, Species, DateOfBirth, HoldingId
FROM Animal;

DROP TABLE Animal;
ALTER TABLE Animal_New RENAME TO Animal;

CREATE UNIQUE INDEX AnimalKeeper_OnePrimary
ON AnimalKeeper (AnimalId)
WHERE IsPrimary = 1;

CREATE TRIGGER AnimalKeeper_MaximumFour
BEFORE INSERT ON AnimalKeeper
WHEN (SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = NEW.AnimalId) >= 4
BEGIN
    SELECT RAISE(ABORT, 'An animal cannot have more than four keepers');
END;

CREATE TRIGGER AnimalKeeper_MaximumFourOnMove
BEFORE UPDATE OF AnimalId ON AnimalKeeper
WHEN NEW.AnimalId <> OLD.AnimalId
    AND (SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = NEW.AnimalId) >= 4
BEGIN
    SELECT RAISE(ABORT, 'An animal cannot have more than four keepers');
END;

PRAGMA foreign_keys = ON;
