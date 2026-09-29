# Demo Guide

Status: draft, 29 September 2026. Standard track only; the shallow and deep tracks are sketched at the end. Built and proved: the legacy app and its screenshots, the golden master, hop 1's law, prompt and checks, and hosting on Azure. Built: the demo command, `./demo.sh`, which does every step that is not part of the story. `./demo.sh start` and `./demo.sh finish` have been run for real (29 September 2026); `publish` and `backup` have not yet, so expect rough edges there. Not built yet: hop 2, the code page and the recordings; they are marked. Screenshots of the original app are in `demo/screens/legacy`; screenshots of the app after hop 1 are in `demo/screens/joint-keepers`, from Cosine's passing run of the hop 1 prompt on 27 September 2026.

## The Story in One Breath

A government service built fifteen years ago still works, but nobody wants to touch it. A new law is passed today and comes into force on 1 October, so the system has to be ready before then. We ask an AI coding agent to change the old code to meet the law, and prove it. Then we ask it to modernise the whole service, and prove nothing changed. The service and the law are fictional; everything else is real.

## Before You Start

Set up your Mac once with the install guide. Then, about ten minutes before each demo, open Terminal, go into the demo folder with `cd joint-keepers`, and run:

    ./demo.sh start

It checks your Mac, gets the latest code, starts the app on Azure, puts the original app back on it with a fresh database, and starts a fresh copy of the code for this run. It takes about three minutes and ends by printing the app's address and the words to type into Cosine. Open the address in the browser.

Not automated yet: clearing Cosine's saved memories from earlier runs, because where Cosine keeps them has not been found.

Have Terminal, the browser and this guide open, and the fallback screenshots to hand.

## Running Order

| Time | Section |
| --- | --- |
| 0:00 to 1:30 | The scene |
| 1:30 to 2:30 | The safety net |
| 2:30 to 6:00 | Hop 1: the new law, in the old code |
| 6:00 to 7:00 | Proof after hop 1 |
| 7:00 to 10:00 | Hop 2: modernise |
| 10:00 to 11:00 | Proof after hop 2 |
| 11:00 to 12:00 | Close |

## The Scene (0:00 to 1:30)

Show: the legacy app on its Azure address, or `01-holdings.png`, `03-holding-register.png` and `04-animal-details.png`.

Say: 'This is Register livestock, a fictional government service. Keepers register the farms they run, the animals on them, and every time an animal moves between farms. It was built on Microsoft technology from the late 2000s, and it only runs on Windows.'

Then show one piece of the old code (the code page, not built yet; for now `legacy/RegisterLivestock/Movement.aspx.vb` in any viewer). Point at:

1. The database query built by gluing text together, which is how SQL injection attacks happen: typed input gets run as a database command.
2. The empty 'Catch' block, where errors are caught and silently thrown away. If the animal's location fails to update, the movement is still reported as recorded.
3. The business rules, such as 'an animal cannot move to the holding it is already on', sitting inside the button's click handler, where nothing can test them on their own.
4. The tag number check, copied into two pages with small differences, so the two pages disagree about what a valid tag is.

## The Safety Net (1:30 to 2:30)

Show: the scenarios in `golden/scenarios.json`, and the golden results folder.

Say: 'Before touching anything, we recorded exactly what the old service does. Twelve everyday scenarios, like registering a cow or trying to move an animal to the farm it is already on. For each one we saved what the screen showed and every row in the database. That recording is the standard every change is checked against.'

Then make the limit plain: 'A golden master only protects what the scenarios exercise. Remember the tag number check copied into two pages? No scenario types a lower-case tag, so if the agent merges the two copies into one rule, the check stays green. That is a decision a person has to make on purpose, not something a test makes for you.'

## Hop 1: The New Law, in the Old Code (2:30 to 6:00)

Show: Part A of `docs/joint-keepers-law.md`, the Regulations.

Say: 'Parliament has passed the Livestock Keeping (Joint Keepers) Regulations 2026. They are fictional. From 1 October an animal can have up to four keepers, one of them the primary keeper, and every existing keeper becomes a primary keeper. The system has to be ready before then. And this is the old system: we are changing fifteen-year-old code, not replacing it.'

Start Cosine in the demo folder and type exactly this, the same words every time:

    Carry out the brief in prompts/hop-1-joint-keepers.md

Say as you type: 'The requirements are already written down as a brief in the repository, the way a team would hand over a piece of work, so I just point the agent at it.' While it works, point out that it reads the law, finds where keepers are used in the old pages, writes a migration for the database, and keeps to the old style rather than rewriting everything.

## Proof After Hop 1 (6:00 to 7:00)

When Cosine has finished, run:

    ./demo.sh publish

It saves Cosine's change, sends it to GitHub, starts the build, and shows each step as it finishes. If everything passes, the changed app goes live on Azure.

In about two minutes, plus any wait for a GitHub machine, the Windows build machine checks that every existing animal kept its keeper as primary after the database migration, compiles the changed old code and checks it starts, runs the original scenarios and compares their screens (all the same except the animal page, which the law changes on purpose), runs the six new scenarios for the law and records their results, deploys the changed app to Azure, and checks the live address works.

Then open the changed app on its Azure address, open an animal, and add a second keeper.

If the build fails, the demo command says so and opens the screenshots in `demo/screens/joint-keepers`. Show those straight away, and if there is time, run `./demo.sh backup new-law` to put a saved, working version of the changed app live in about two minutes. The screenshots: `04-animal-details.png` (an existing keeper, now primary from 1 October), `j01-register-two-keepers.png`, `j03-add-keeper.png` and `j05-fifth-keeper-refused.png` (the law's limit of four keepers).

Say: 'Old code, new law, and proof that every screen the law did not touch still shows exactly what it showed before, and that every keeper's record came through the change.'

## Hop 2: Modernise (7:00 to 10:00)

Not built yet. Point Cosine at the hop 2 brief, in fixed words as for hop 1. While it works, point out its task list and that every step is a separate change that can be inspected or undone. Whether it modernises all four screens live, or one live with three done earlier, is decided by rehearsal.

## Proof After Hop 2 (10:00 to 11:00)

Not built yet. The golden master runs against the modern app, including the joint keepers scenarios: all pass. The database structure check passes. Show the modern app next to the old one, and the old and new code side by side.

Say: 'The code is new. The behaviour, including the new law, is identical, and here is the proof. And the database did not change at all.'

## Close (11:00 to 12:00)

Say: 'Every step the agent took was a change a person reviewed and approved. The next hops would be moving the database and the architecture, one at a time, each with the same proof.'

## Afterwards

Run `./demo.sh finish`. It stops the app on Azure, which is deliberately insecure and must not be left running. The next `./demo.sh start` puts the original app back.

## If Something Goes Wrong

The rule: never debug live. Say 'let me show you the one we ran earlier', and move on. Until recordings exist, the fallback for the proof after hop 1 is the screenshots in `demo/screens/joint-keepers`, and for the scene the screenshots in `demo/screens/legacy`. The demo command keeps backups: versions of the app saved from checked rehearsals. `./demo.sh backup new-law` puts the app as it is after the law change live in about two minutes, once Seb has saved that backup; `./demo.sh backup original` puts the original app back. A `backup modern` will follow when hop 2 is built. Each section will also have its recording (not made yet).

## Shallow and Deep Tracks

Shallow: the scene, the law, then straight to the changed and modernised apps running; no agent on screen. Deep: as standard, plus opening the repository in an editor to walk through the code changes and tests after each hop. To be written once the standard track is rehearsed.
