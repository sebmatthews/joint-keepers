# Demo Guide

Status: draft, 27 September 2026. Standard track only; the shallow and deep tracks are sketched at the end. The legacy app and its screenshots exist. Cosine's two hops, the modern app, the database check and the demo command are not built yet, and are marked. Screenshots are in `demo/screens/legacy`, fetched from the latest Windows build with `tools/fetch-run.sh`.

## The Story in One Breath

A government service built fifteen years ago still works, but nobody wants to touch it. We ask an AI coding agent to modernise it, and prove nothing broke. Then a new law arrives, and we ask the agent to change the service to meet it, and prove that too. The service is fictional; everything else is real.

## Before You Start

Run the demo command's pre-flight check (not built yet). Open Terminal in the repository, the browser, and this guide. Have the recordings of each step to hand in case a live step fails.

## Running Order

| Time | Section |
| --- | --- |
| 0:00 to 1:30 | The scene |
| 1:30 to 2:30 | The safety net |
| 2:30 to 6:00 | Hop 1: modernise |
| 6:00 to 7:00 | Proof after hop 1 |
| 7:00 to 10:00 | Hop 2: the new law |
| 10:00 to 11:00 | Proof after hop 2 |
| 11:00 to 12:00 | Close |

## The Scene (0:00 to 1:30)

Show: `01-holdings.png`, then `03-holding-register.png`, then `04-animal-details.png`.

Say: 'This is Register livestock, a fictional government service. Keepers register the farms they run, the animals on them, and every time an animal moves between farms. It was built on Microsoft technology from the late 2000s, and it still runs on Windows only. These are real screenshots, taken from the real app running on a Windows machine this week.'

Then show one piece of the old code (the demo command will open it; for now, `legacy/RegisterLivestock/Movement.aspx.vb` in any viewer). Point at:

1. The database query built by gluing text together, which is how SQL injection attacks happen: typed input gets run as a database command.
2. The empty 'Catch' block, where errors are caught and silently thrown away. If the animal's location fails to update, the movement is still reported as recorded.
3. The business rules, such as 'an animal cannot move to the holding it is already on', sitting inside the button's click handler, where nothing can test them on their own.
4. The tag number check, copied into two pages with small differences, so the two pages disagree about what a valid tag is.

## The Safety Net (1:30 to 2:30)

Show: the scenarios in `golden/scenarios.json`, and the golden results folder.

Say: 'Before touching anything, we recorded exactly what the old service does. Twelve everyday scenarios, like registering a cow or trying to move an animal to the farm it is already on. For each one we saved what the screen showed and every row in the database. That recording is the standard the new version must meet, exactly. We also took a snapshot of the database's structure, and hop 1 is not allowed to change it.'

The structure snapshot and its check are not built yet.

## Hop 1: Modernise (2:30 to 6:00)

Not built yet. Hop 1 scope is an open decision, so both versions are written here until it is settled.

Version A, all four screens live: paste the hop 1 prompt into Cosine. While it works, point out its task list moving from pending to done. Say: 'Every step it takes is saved as a separate change we can inspect or undo.' Risk: the agent may not finish in three and a half minutes; if it overruns, jump to the checkpoint after hop 1 and carry on.

Version B, one screen live: say 'We modernised three of the four screens earlier with exactly the same prompt; now watch it do the last one.' Paste the one-screen prompt. Lower risk, and the time left over goes to the proof.

## Proof After Hop 1 (6:00 to 7:00)

Not built yet. The demo command runs the golden master check against the modern app: all twelve scenarios pass, and the database structure check passes. Then show the modern app running in the browser, next to `01-holdings.png`.

Say: 'The code is new. The behaviour is identical, and here is the proof. And the database did not change at all.'

## Hop 2: The New Law (7:00 to 10:00)

Not built yet. Say: 'Now Parliament passes the Livestock Keeping (Joint Keepers) Regulations 2026. They are fictional. From today, an animal can have up to four keepers, one of them the primary keeper.' Paste the hop 2 prompt. Point out that this changes the shape of the data, not just the screens: a new table, and every existing animal's keeper moved into it.

## Proof After Hop 2 (10:00 to 11:00)

Not built yet. Show every existing animal still has its keeper, now as primary. Add a second keeper to an animal on screen. Run the checks: the new rules pass, and the original scenarios still pass apart from the deliberate change.

## Close (11:00 to 12:00)

Say: 'Every step the agent took was a change a person reviewed and approved. The next hops would be moving the database and the architecture, one at a time, each with the same proof.'

## If Something Goes Wrong

Not built yet. The demo command will jump to the checkpoint for any section, and each section will have its recording. The rule: never debug live. Say 'let me show you the one we ran earlier', and move on.

## Shallow and Deep Tracks

Shallow: the scene, then straight to the modern app running with joint keepers; no Cosine on screen. Deep: as standard, plus opening the repository in an editor to walk through the code changes and tests after each hop. To be written once the standard track is rehearsed.
