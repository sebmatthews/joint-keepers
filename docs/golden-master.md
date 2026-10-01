# The Golden Master Approach

Status: draft, 29 September 2026. The legacy half and the checks after the law change are built and proved. The modern half is written for the modernisation stage.

## What It Is

A golden master test records what an existing system actually does, and then requires the new system to do exactly the same. Nobody writes down what the system should do. The old system's own answers are the standard. This matters for legacy modernisation because the old system's behaviour, including its oddities, is what users and other systems depend on, and much of it is written down nowhere except in the code.

For this demo it gives the audience a clear promise: the code was rewritten, and here is proof that the service behaves exactly as it did before.

## How It Works Here

There are twelve scenarios, written in plain language in `golden/scenarios.json`. Each one is something a user does, such as 'Register a cow with a correctly formed tag number on Hollowmere Farm' or 'Try to move an animal to the holding it is already on'. Four only look at screens, four register animals and four record movements. Six of the eight that try to change something are attempts the service should refuse.

Before each scenario, the database is reset to the pristine copy in `db/livestock.db`, so every scenario starts from the same place.

After each scenario, two things are recorded:

1. What the screen shows: any message (such as 'Tag number must be LV followed by 8 digits') and the rows of every table on the page.
2. Every row of every table in the database.

The legacy app's recording is the golden result. It is made on GitHub's Windows build machine, because the legacy app only runs on Windows, and saved in `golden/results`, one file per scenario.

The demo changes the legacy app to meet a new law first (the new-law stage), then modernises it (the modernisation stage). How the checks work after the law change is set out below. After modernising, the scenarios run against the modern app and every result must match exactly. Any difference, however small, is a failure.

## Two Apps, One Set of Scenarios

The scenarios say what to do, not which buttons to press. A driver for each app turns the steps into clicks and typing on that app's screens. The legacy driver is `golden/drivers/legacy.mjs`. The modern driver is written for the modern app in the modernisation stage.

## What the Modern App Must Keep

Because the comparison is exact, the modern app built in the modernisation stage must keep, word for word and character for character:

1. Every message the legacy app shows.
2. Dates shown as DD/MM/YYYY.
3. The same columns, in the same order, in each table on screen.
4. The same database tables and rows, since the modernisation stage does not change the database.

These go into the modernisation brief and AGENTS.md. The look of the screens is free to change, which is the point of modernising.

## What It Does Not Cover

The legacy app has a validation rule copied into two pages with small differences, one of the planted flaws. The registration page trims spaces from a tag number but does not accept lower case. The movement page accepts lower case but does not trim spaces. No scenario exercises that difference, so the golden master will not notice if the modern app settles on one rule. Decided on 27 September 2026: this is left untested on purpose, and used as a talking point about the limits of any test, so that a sensible tidy-up by the agent cannot fail the check live.

## After the Law Change

The new-law stage changes the database's structure on purpose, through the migration in db/migrations. On a branch with a migration, the build therefore does three things instead of recording:

1. Checks the migration: every animal still has exactly its old keeper, now as primary, dated from the law's commencement, 1 October 2026 (`tools/check-migration.mjs`).
2. Runs the twelve original scenarios and compares what the screen shows with the recorded golden results. The database is not compared, because its structure has changed by design. The animal page (scenario S04) is expected to change, because the law adds its keepers table, and it must then match the approved new-law result in `golden/results-new-law/S04.json` exactly; every other scenario must match the original results exactly.
3. Runs the six scenarios for the law, J01 to J06, in `golden/scenarios-joint-keepers.json`, and compares each screen with its approved result in `golden/results-new-law`.

The approved new-law results come from the build of the new-law backup (29 September 2026, on Cosine's passing run replayed onto main), checked by hand against the law document. They are also the standard the modernisation stage must match.

Why the animal page is checked against an approved result: in the first rehearsal (29 September 2026), Cosine's change left the keepers table off the animal page. Accepting any change to that page let it through; only the add-a-keeper scenarios caught it.

Keepers added through the screens are dated the day they are added, so the runner replaces today's date with '<today>' in everything it records or compares.

## Running It

On GitHub, the 'Legacy app' workflow runs on every push that touches the legacy app, the database, the scenarios or the tools. To bring the latest results and screenshots down into the repository, run `tools/fetch-run.sh` from the top of the repository, then commit what it changed. A push that only adds an existing commit under a new branch name does not start a build; start it with `gh workflow run legacy.yml --ref <branch>`.

On a Mac, once the modern app exists, the check is run from the `golden` folder with `npm run compare`, with `APP_URL` and `APP_DB` set to the modern app's address and database file, and `DRIVER=modern`. The demo command, when it is built, will do this in one step.
