# The Golden Master Approach

Status: draft, 27 September 2026. The legacy half is built. The modern half is written when hop 1 is rehearsed.

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

After hop 1, the same scenarios run against the modern app on the Mac, and every result must match the golden result exactly. Any difference, however small, is a failure.

## Two Apps, One Set of Scenarios

The scenarios say what to do, not which buttons to press. A driver for each app turns the steps into clicks and typing on that app's screens. The legacy driver is `golden/drivers/legacy.mjs`. The modern driver is written for the modern app when hop 1 is rehearsed, and is part of the checkpoint after hop 1.

## What the Modern App Must Keep

Because the comparison is exact, the modern app must keep, word for word and character for character:

1. Every message the legacy app shows.
2. Dates shown as DD/MM/YYYY.
3. The same columns, in the same order, in each table on screen.
4. The same database tables and rows, since hop 1 does not change the database.

These go into the hop 1 prompt and Cosine's project conventions file. The look of the screens is free to change, which is the point of hop 1.

## What It Does Not Cover

The legacy app has a validation rule copied into two pages with small differences, one of the planted flaws. The registration page trims spaces from a tag number but does not accept lower case. The movement page accepts lower case but does not trim spaces. No scenario exercises that difference, so the golden master will not notice if the modern app settles on one rule. That is a decision for Seb: add a scenario that pins the old behaviour, or leave it as a talking point about the limits of any test.

## Running It

On GitHub, the 'Legacy app' workflow records the golden results on every push that touches the legacy app, the database or the scenarios. To bring the results and the screenshots down into the repository, run `tools/fetch-run.sh` from the top of the repository, then commit what it changed.

On a Mac, once the modern app exists, the check is run from the `golden` folder with `npm run compare`, with `APP_URL` and `APP_DB` set to the modern app's address and database file, and `DRIVER=modern`. The demo command, when it is built, will do this in one step.
