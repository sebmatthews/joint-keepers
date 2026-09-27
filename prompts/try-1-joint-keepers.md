# Try 1: Joint Keepers in the Legacy App

An exploratory first run, to see how the agent handles the legacy code. Not the demo version of the prompt.

This repository contains a legacy ASP.NET Web Forms app written in VB.NET, in legacy/RegisterLivestock, using a SQLite database whose structure is in db/schema.sql. A new (fictional) law, the Livestock Keeping (Joint Keepers) Regulations 2026, says an animal may have between one and four keepers, exactly one of whom is the primary keeper. Change the legacy app to meet it.

1. Add a new table, AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded), replacing the single keeper on Animal. Write the change as a migration script at db/migrations/001-joint-keepers.sql, which also moves every existing animal's keeper into AnimalKeeper as its primary keeper. Do not run it, and do not change db/livestock.db.
2. On the holding page, let the 'Register an animal' form take a primary keeper and up to three more keepers.
3. On the animal page, list all its keepers with the primary one marked.
4. Keep the app's existing style and structure. It is meant to stay legacy code: do not modernise or refactor anything the law does not require.
5. Do not change anything in golden/, tools/, docs/, prompts/ or .github/.
