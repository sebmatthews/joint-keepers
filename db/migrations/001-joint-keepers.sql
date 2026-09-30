-- The Livestock Keeping (Joint Keepers) Regulations 2026, in force 1 October 2026.
-- An animal has one to four keepers, exactly one of them primary. Each existing keeper
-- becomes the animal's primary keeper, dated from the commencement date (fixed, not today,
-- so the migrated data is the same whenever it is made).

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

ALTER TABLE Animal DROP COLUMN KeeperId;
