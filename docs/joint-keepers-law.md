# The Joint Keepers Change

Status: agreed 27 September 2026, including every item marked 'Decision'.

This is the single source for the legislative change in the new-law stage. The new-law brief, `prompts/new-law.md`, points at it, the golden master scenarios for the change are written from it, and the demo presents Part A to the audience. Part A is fictional law. Part B is what the service must do to comply.

## Part A: The Regulations

The Livestock Keeping (Joint Keepers) Regulations 2026. These regulations are fictional and exist only for this demo.

1. These Regulations come into force on 1 October 2026.
2. Every registered animal must have at least one and no more than four keepers.
3. One of an animal's keepers must be recorded as its primary keeper, and only one.
4. The same person may not be recorded as a keeper of the same animal more than once.
5. On the day these Regulations come into force, the person recorded as an animal's keeper becomes its primary keeper.

Decision: the commencement date is 1 October 2026. It must be a fixed date, because it is also the 'date added' given to every existing keeper, and the golden master needs the migrated data to be the same whenever it is run.

## Part B: What the Service Must Do

### Data

A new table, AnimalKeeper, with the columns AnimalId, KeeperId, IsPrimary (1 or 0) and DateAdded (YYYY-MM-DD). One row per keeper of an animal; an animal and keeper pair appears only once.

The KeeperId column is removed from Animal.

The change is made by a migration script, db/migrations/001-joint-keepers.sql, which creates AnimalKeeper, copies every animal's existing keeper into it as the primary keeper with DateAdded 2026-10-01, and removes KeeperId from Animal. The database itself should also refuse a second primary keeper for an animal, and a fifth keeper.

Keepers added through the service after that get the date they were added.

### Screens

Holding page, animal register table: the 'Keeper' column shows the animal's primary keeper. The heading stays 'Keeper'.

Holding page, 'Register an animal' form: the single keeper list becomes 'Primary keeper' (required), followed by three optional 'Additional keeper' lists.

Animal page: the single 'Keeper' row is replaced by a Keepers table with the columns 'Keeper', 'Role' ('Primary' or 'Additional') and 'Date added' (DD/MM/YYYY), primary keeper first, then the others by name. Below it, an 'Add a keeper' form: one keeper list and an 'Add keeper' button.

Decision: adding a keeper to an existing animal is in scope, because the demo's proof after the new law adds a second keeper on screen. Removing a keeper, and changing which keeper is primary, are out of scope.

Every other screen stays as it is.

### Names of Screen Elements

The checks drive the screens by the IDs of their elements, so these are fixed. Existing IDs stay as they are.

| Screen | Element | ID |
| --- | --- | --- |
| Holding page | Primary keeper list (the existing keeper list, relabelled) | ddlKeeper |
| Holding page | Additional keeper lists | ddlKeeper2, ddlKeeper3, ddlKeeper4 |
| Animal page | Keepers table | gvKeepers, with the class 'grid' like the app's other tables |
| Animal page | Add a keeper: list and button | ddlAddKeeper, btnAddKeeper |
| Animal page | Messages from adding a keeper | lblMessage, with the class 'message' like the app's other messages |

### Messages

Every existing message stays word for word. The new ones, exactly:

| When | Message |
| --- | --- |
| Registering, no primary keeper chosen | Select a keeper (the existing message, unchanged) |
| Registering, the same keeper chosen twice | Select each keeper only once |
| Adding a keeper, none chosen | Select a keeper to add |
| Adding a keeper already recorded for the animal | This keeper is already recorded for this animal |
| Adding a fifth keeper | An animal cannot have more than four keepers |
| Adding a keeper successfully | Keeper [name] added |

## How the Change Is Checked

The existing golden master scenarios run against the changed app. Scenarios that do not involve keepers must match exactly. The animal page and registration scenarios change on purpose, and those differences are expected and listed.

New scenarios for the law, recorded once the change is approved:

1. Register an animal with a primary keeper and one additional keeper.
2. Try to register an animal with the same keeper chosen twice.
3. Add a second keeper to an existing animal.
4. Try to add a keeper who is already recorded for the animal.
5. Try to add a fifth keeper.
6. Try to add a keeper without choosing one.

A migration check confirms that, after the migration, every animal has exactly one keeper, marked primary, that it is the keeper the animal had before, and that its date added is 2026-10-01.

Because keepers added through the service carry the day's date, the golden master runner will replace today's date with a placeholder before comparing, so recordings made on different days still match.
