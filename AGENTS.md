# Register Livestock: Notes for Coding Agents

This repository holds a demo of AI-assisted change to a legacy government system. The service, 'Register livestock', is fictional.

## Layout

legacy/RegisterLivestock is the legacy app: ASP.NET Web Forms, VB.NET, .NET Framework 4.8, SQLite through System.Data.SQLite. It only builds and runs on Windows; changes are built and tested by the GitHub Actions workflow on push.

db/ holds the database structure, seed data and the pristine database.

golden/ holds the golden master: recorded behaviour that changes must be checked against.

## Always

Keep changes to what the task asks for.

Write database structure changes as numbered migration scripts in db/migrations.

Keep every message the app shows word for word unless the task says to change it.

Show dates as DD/MM/YYYY.

## Never Change

db/livestock.db, demo.sh, or anything in golden/, docs/, prompts/, tools/, demo/ or .github/, unless the task explicitly says so.
