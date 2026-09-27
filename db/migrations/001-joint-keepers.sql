-- Allow between one and four keepers for each animal, with one primary keeper.

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE TABLE AnimalKeeper (
    AnimalId   INTEGER NOT NULL REFERENCES Animal(AnimalId),
    KeeperId   INTEGER NOT NULL REFERENCES Keeper(KeeperId),
    IsPrimary  INTEGER NOT NULL CHECK (IsPrimary IN (0, 1)),
    DateAdded  TEXT NOT NULL,
    PRIMARY KEY (AnimalId, KeeperId)
);

INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded)
SELECT AnimalId, KeeperId, 1, DATE('now')
FROM Animal;

CREATE TABLE AnimalNew (
    AnimalId    INTEGER PRIMARY KEY,
    TagNumber   TEXT NOT NULL UNIQUE,
    Species     TEXT NOT NULL,
    DateOfBirth TEXT NOT NULL,
    HoldingId   INTEGER NOT NULL REFERENCES Holding(HoldingId)
);

INSERT INTO AnimalNew (AnimalId, TagNumber, Species, DateOfBirth, HoldingId)
SELECT AnimalId, TagNumber, Species, DateOfBirth, HoldingId
FROM Animal;

DROP TABLE Animal;
ALTER TABLE AnimalNew RENAME TO Animal;

CREATE UNIQUE INDEX IX_AnimalKeeper_Primary
ON AnimalKeeper (AnimalId)
WHERE IsPrimary = 1;

CREATE TRIGGER AnimalKeeper_MaximumFour_Insert
BEFORE INSERT ON AnimalKeeper
WHEN (SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = NEW.AnimalId) >= 4
BEGIN
    SELECT RAISE(ABORT, 'An animal cannot have more than four keepers');
END;

CREATE TRIGGER AnimalKeeper_MaximumFour_Update
BEFORE UPDATE OF AnimalId ON AnimalKeeper
WHEN NEW.AnimalId <> OLD.AnimalId
 AND (SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = NEW.AnimalId) >= 4
BEGIN
    SELECT RAISE(ABORT, 'An animal cannot have more than four keepers');
END;

COMMIT;

PRAGMA foreign_keys = ON;
