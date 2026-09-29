-- The Livestock Keeping (Joint Keepers) Regulations 2026: an animal has one to four keepers, exactly one of them primary.
-- Every existing keeper becomes the animal's primary keeper on the commencement date, 1 October 2026.
-- The date is fixed so the migrated data is the same whenever the migration is run.

-- Animal is rebuilt to remove KeeperId; SQLite cannot drop a column used in a foreign key.
PRAGMA foreign_keys = OFF;

BEGIN;

CREATE TABLE AnimalKeeper (
    AnimalId    INTEGER NOT NULL REFERENCES Animal(AnimalId),
    KeeperId    INTEGER NOT NULL REFERENCES Keeper(KeeperId),
    IsPrimary   INTEGER NOT NULL CHECK (IsPrimary IN (0, 1)),
    DateAdded   TEXT NOT NULL,
    PRIMARY KEY (AnimalId, KeeperId)
);

CREATE UNIQUE INDEX AnimalKeeperOnePrimary ON AnimalKeeper (AnimalId) WHERE IsPrimary = 1;

CREATE TRIGGER AnimalKeeperNoMoreThanFour
BEFORE INSERT ON AnimalKeeper
WHEN (SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = NEW.AnimalId) >= 4
BEGIN
    SELECT RAISE(ABORT, 'An animal cannot have more than four keepers');
END;

INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded)
SELECT AnimalId, KeeperId, 1, '2026-10-01' FROM Animal;

CREATE TABLE Animal_new (
    AnimalId    INTEGER PRIMARY KEY,
    TagNumber   TEXT NOT NULL UNIQUE,
    Species     TEXT NOT NULL,
    DateOfBirth TEXT NOT NULL,
    HoldingId   INTEGER NOT NULL REFERENCES Holding(HoldingId)
);

INSERT INTO Animal_new (AnimalId, TagNumber, Species, DateOfBirth, HoldingId)
SELECT AnimalId, TagNumber, Species, DateOfBirth, HoldingId FROM Animal;

DROP TABLE Animal;
ALTER TABLE Animal_new RENAME TO Animal;

COMMIT;

PRAGMA foreign_keys = ON;
