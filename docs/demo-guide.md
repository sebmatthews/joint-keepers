# Demo Guide

Status: draft, 29 September 2026. Standard track only; the shallow and deep tracks are sketched at the end. Built and proved: the legacy app and its screenshots, the golden master, hop 1's law, prompt and checks, and hosting on Azure. Not built yet: hop 2, the demo command, the code page and the recordings; they are marked, and until the demo command exists the steps it will do are written out here by hand. Screenshots of the original app are in `demo/screens/legacy`, fetched from the latest build with `tools/fetch-run.sh`. Screenshots of the app after hop 1 are in `demo/screens/joint-keepers`, from Cosine's passing run of the hop 1 prompt on 27 September 2026.

## The Story in One Breath

A government service built fifteen years ago still works, but nobody wants to touch it. A new law is passed today and comes into force on 1 October, so the system has to be ready before then. We ask an AI coding agent to change the old code to meet the law, and prove it. Then we ask it to modernise the whole service, and prove nothing changed. The service and the law are fictional; everything else is real.

## Before You Start

Set up your Mac first with the install guide. Then, before each demo:

1. Start the web app in the Azure portal.
2. Put the original app back on Azure. The address serves whatever was last built from main or a branch starting 'demo/', so after a previous run it may be showing the changed app. In Terminal, in the repository, run `gh workflow run legacy.yml --ref main`, wait about a minute and a half, plus any wait for a GitHub machine to become free, then open the address. This works because main has no database migrations, so it always builds the original app. Open an animal: the original app shows a single Keeper line and no Keepers table.
3. Start a fresh branch for this run from the latest main. Its name must start with 'demo/', or the build will check the change but not put it on Azure:

        git switch main
        git pull
        git switch -c demo/live-$(date +%d%m-%H%M)

4. Clear Cosine's saved memories from any earlier run. Not written yet: where Cosine keeps them has not been found.

Open Terminal in the repository, the browser, and this guide. Have the fallback screenshots, and the recordings of each step once they exist, to hand. The demo command's pre-flight check and reset will replace steps 2 to 4 (not built yet).

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

Start Cosine in the repository, on the demo/ branch made before the demo, and give it the hop 1 prompt: 'Carry out the brief in prompts/hop-1-joint-keepers.md'. While it works, point out that it reads the law, finds where keepers are used in the old pages, writes a migration for the database, and keeps to the old style rather than rewriting everything.

## Proof After Hop 1 (6:00 to 7:00)

Send the change to GitHub and start the build (the demo command will do this; not built yet). If Cosine has not committed its work itself, commit it first, then push:

    git add -A
    git commit -m "Joint Keepers Regulations"
    git push -u origin HEAD

Wait about ten seconds, then check a build has started for your branch with `gh run list --workflow legacy.yml --branch $(git branch --show-current) --limit 1`. If nothing is listed under the heading line, start the build yourself with `gh workflow run legacy.yml --ref $(git branch --show-current)`. To follow it, run `gh run watch`, choose the line showing your branch and press Enter; it shows each step as it finishes.

In about a minute and a half, plus any wait for a GitHub machine, the Windows build machine checks that every existing animal kept its keeper as primary after the database migration, compiles the changed old code and checks it starts, runs the original scenarios and compares their screens (all the same except the animal page, which the law changes on purpose), runs the six new scenarios for the law and records their results, deploys the changed app to Azure, and checks the live address works.

Then open the changed app on its Azure address, open an animal, and add a second keeper.

If the build or the deploy fails, show the screenshots in `demo/screens/joint-keepers` instead: `04-animal-details.png` (an existing keeper, now primary from 1 October), `j01-register-two-keepers.png`, `j03-add-keeper.png` and `j05-fifth-keeper-refused.png` (the law's limit of four keepers).

Say: 'Old code, new law, and proof that every screen the law did not touch still shows exactly what it showed before, and that every keeper's record came through the change.'

## Hop 2: Modernise (7:00 to 10:00)

Not built yet. Give Cosine the hop 2 prompt. While it works, point out its task list and that every step is a separate change that can be inspected or undone. Whether it modernises all four screens live, or one live with three done earlier, is decided by rehearsal.

## Proof After Hop 2 (10:00 to 11:00)

Not built yet. The golden master runs against the modern app, including the joint keepers scenarios: all pass. The database structure check passes. Show the modern app next to the old one, and the old and new code side by side.

Say: 'The code is new. The behaviour, including the new law, is identical, and here is the proof. And the database did not change at all.'

## Close (11:00 to 12:00)

Say: 'Every step the agent took was a change a person reviewed and approved. The next hops would be moving the database and the architecture, one at a time, each with the same proof.'

## Afterwards

Put the original app back on Azure with `gh workflow run legacy.yml --ref main`, so the next demo starts from the old version (the demo command's reset will do this; not built yet). Wait for it to finish, then stop the web app in the Azure portal.

## If Something Goes Wrong

The rule: never debug live. Until recordings exist, the fallback for the proof after hop 1 is the screenshots in `demo/screens/joint-keepers`, and for the scene the screenshots in `demo/screens/legacy`. Not built yet: the demo command will jump to the checkpoint for any section, and each section will have its recording. Say 'let me show you the one we ran earlier', and move on.

## Shallow and Deep Tracks

Shallow: the scene, the law, then straight to the changed and modernised apps running; no agent on screen. Deep: as standard, plus opening the repository in an editor to walk through the code changes and tests after each hop. To be written once the standard track is rehearsed.
