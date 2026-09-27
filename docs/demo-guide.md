# Demo Guide

Status: draft, 27 September 2026. Standard track only; the shallow and deep tracks are sketched at the end. Built and proved: the legacy app and its screenshots, the golden master, hop 1's law, prompt and checks, and hosting on Azure. Not built yet: hop 2, the demo command, the code page and the recordings; they are marked. Screenshots are in `demo/screens/legacy`, fetched from the latest build with `tools/fetch-run.sh`.

## The Story in One Breath

A government service built fifteen years ago still works, but nobody wants to touch it. A new law is passed today and comes into force on 1 October, so the system has to be ready before then. We ask an AI coding agent to change the old code to meet the law, and prove it. Then we ask it to modernise the whole service, and prove nothing changed. The service and the law are fictional; everything else is real.

## Before You Start

Start the web app in the Azure portal and open its address a minute early, to wake it. Run the demo command's pre-flight check and reset to the start (not built yet). Open Terminal in the repository, the browser, and this guide. Have the recordings of each step to hand.

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

Give Cosine the hop 1 prompt: 'Carry out the brief in prompts/hop-1-joint-keepers.md'. While it works, point out that it reads the law, finds where keepers are used in the old pages, writes a migration for the database, and keeps to the old style rather than rewriting everything.

## Proof After Hop 1 (6:00 to 7:00)

Push the change and start the build (the demo command will do both; not built yet). In about a minute and a half the Windows build machine compiles the changed old code, checks every existing animal kept its keeper as primary, runs the original scenarios (all the same except the animal page, which the law changes on purpose), runs the six new scenarios for the law, and deploys the changed app to Azure.

Then open the changed app on its Azure address, open an animal, and add a second keeper.

Say: 'Old code, new law, and proof that everything the law did not touch still behaves exactly as before.'

## Hop 2: Modernise (7:00 to 10:00)

Not built yet. Give Cosine the hop 2 prompt. While it works, point out its task list and that every step is a separate change that can be inspected or undone. Whether it modernises all four screens live, or one live with three done earlier, is decided by rehearsal.

## Proof After Hop 2 (10:00 to 11:00)

Not built yet. The golden master runs against the modern app, including the joint keepers scenarios: all pass. The database structure check passes. Show the modern app next to the old one, and the old and new code side by side.

Say: 'The code is new. The behaviour, including the new law, is identical, and here is the proof. And the database did not change at all.'

## Close (11:00 to 12:00)

Say: 'Every step the agent took was a change a person reviewed and approved. The next hops would be moving the database and the architecture, one at a time, each with the same proof.'

## Afterwards

Reset to the start (not built yet). Stop the web app in the Azure portal.

## If Something Goes Wrong

Not built yet. The demo command will jump to the checkpoint for any section, and each section will have its recording. The rule: never debug live. Say 'let me show you the one we ran earlier', and move on.

## Shallow and Deep Tracks

Shallow: the scene, the law, then straight to the changed and modernised apps running; no agent on screen. Deep: as standard, plus opening the repository in an editor to walk through the code changes and tests after each hop. To be written once the standard track is rehearsed.
