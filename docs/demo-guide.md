# Demo Guide

The script for the Joint Keepers demo: what to show and say in each section, and what to do if something goes wrong. It runs for about ten minutes. Screenshots of the original app are in `demo/screens/legacy`; screenshots of the app after the new law are in `demo/screens/joint-keepers`.

## The Story in One Breath

A government service built fifteen years ago still works, but nobody wants to touch it. A new law is passed today and comes into force on 1 October, so the system has to be ready before then. We ask an AI coding agent to change the old code to meet the law, and we prove that it did, and that nothing else changed. The service and the law are fictional; everything else is real.

## Before You Start

Set up your Mac once with the install guide. Then, about ten minutes before each demo, open Terminal, go into the demo folder with `cd joint-keepers`, and run:

    ./demo.sh start

It checks your Mac, gets the latest code, starts the app on Azure, puts the original app back on it with a fresh database, and starts a fresh copy of the code for this run. It takes about three minutes and ends by printing the app's address and the words to type into Cosine. Open the address in the browser.

If your Cosine set-up keeps memories between sessions, clear them now, so every run starts the same.

Have Terminal, the browser and this guide open, and the fallback screenshots to hand.

## Running Order

| Time | Section |
| --- | --- |
| 0:00 to 2:00 | The scene |
| 2:00 to 3:00 | The safety net |
| 3:00 to 7:00 | The new law, in the old code |
| 7:00 to 9:00 | Proof after the new law |
| 9:00 to 10:00 | Close, and where it goes next |

## The Scene (0:00 to 2:00)

Show: the legacy app on its Azure address, or `01-holdings.png`, `03-holding-register.png` and `04-animal-details.png`. Click into a holding and an animal so the audience sees a working service.

Say: 'This is Register livestock, a fictional government service. Keepers register the farms they run, the animals on them, and every time an animal moves between farms. It was built on Microsoft technology from the late 2000s, and it only runs on Windows.'

Then open `legacy/RegisterLivestock/Movement.aspx.vb` in any viewer or editor. Point at:

1. The database query built by gluing text together, which is how SQL injection attacks happen: typed input gets run as a database command.
2. The empty 'Catch' block, where errors are caught and silently thrown away. If the animal's location fails to update, the movement is still reported as recorded.
3. The business rules, such as 'an animal cannot move to the holding it is already on', sitting inside the button's click handler, where nothing can test them on their own.
4. The tag number check, copied into two pages with small differences, so the two pages disagree about what a valid tag is.

Say: 'Code like this is everywhere in government. It works, so nobody dares touch it, and every change gets slower and riskier.'

## The Safety Net (2:00 to 3:00)

Show: the scenarios in `golden/scenarios.json`, and the golden results folder.

Say: 'Before touching anything, we recorded exactly what the old service does. Twelve everyday scenarios, like registering a cow or trying to move an animal to the farm it is already on. For each one we saved what the screen showed and every row in the database. That recording is the standard every change is checked against.'

Then make the limit plain: 'A golden master only protects what the scenarios exercise. Remember the tag number check copied into two pages? No scenario types a lower-case tag, so if the agent merges the two copies into one rule, the check stays green. That is a decision a person has to make on purpose, not something a test makes for you.'

## The New Law, in the Old Code (3:00 to 7:00)

Show: Part A of `docs/joint-keepers-law.md`, the Regulations.

Say: 'Parliament has passed the Livestock Keeping (Joint Keepers) Regulations 2026. They are fictional. From 1 October an animal can have up to four keepers, one of them the primary keeper, and every existing keeper becomes a primary keeper. The system has to be ready before then. And this is the old system: we are changing fifteen-year-old code, not replacing it.'

Start Cosine in the demo folder and type exactly this, the same words every time:

    Carry out the brief in prompts/new-law.md

Say as you type: 'The requirements are already written down as a brief in the repository, the way a team would hand over a piece of work, so I just point the agent at it.'

While it works, point out that it reads the law, finds where keepers are used in the old pages, writes a migration for the database, and keeps to the old style rather than rewriting everything. When it finishes, show the list of files it changed: five, and nothing else.

## Proof After the New Law (7:00 to 9:00)

When Cosine has finished, run:

    ./demo.sh publish

It saves Cosine's change, sends it to GitHub, starts the build, and shows each step as it finishes. If everything passes, the changed app goes live on Azure.

In about two minutes, plus any wait for a GitHub machine, the Windows build machine checks that every existing animal kept its keeper as primary after the database migration, compiles the changed old code and checks it starts, runs the original scenarios and compares their screens (all the same except the animal page, which the law changes on purpose and which must match its approved version), runs the six new scenarios for the law and checks each against its approved result, deploys the changed app to Azure, and checks the live address works. Narrate each step as it ticks off.

Then open the changed app on its Azure address, open an animal, and add a second keeper.

If the build fails, the demo command says so and opens the screenshots in `demo/screens/joint-keepers`. Show those straight away, and if there is time, run `./demo.sh backup new-law` to put a saved, working version of the changed app live in about two minutes. The screenshots: `04-animal-details.png` (an existing keeper, now primary from 1 October), `j01-register-two-keepers.png`, `j03-add-keeper.png` and `j05-fifth-keeper-refused.png` (the law's limit of four keepers).

Say: 'Old code, new law, and proof that every screen the law did not touch still shows exactly what it showed before, and that every keeper's record came through the change.'

## Close, and Where It Goes Next (9:00 to 10:00)

Say: 'Every step the agent took was a change a person could review and approve, and every change was proved against the old system's own behaviour before it went live.'

Then the future expansion: 'The same foundation takes this further. The next stage is modernisation: the agent rewrites the changed service in modern technology, and the same golden master, including the new law's scenarios, proves the new code behaves exactly like the old. After that, moving the database and then the architecture, one step at a time, each with the same proof. Never the code and the data in the same step.'

## Afterwards

Run `./demo.sh finish`. It stops the app on Azure, which is deliberately insecure and must not be left running. The next `./demo.sh start` puts the original app back.

## If Something Goes Wrong

The rule: never debug live. Say 'let me show you the one we ran earlier', and move on.

The fallback for the proof after the new law is the screenshots in `demo/screens/joint-keepers`, and for the scene the screenshots in `demo/screens/legacy`. The demo command keeps backups: versions of the app saved from checked rehearsals. `./demo.sh backup new-law` puts the app as it is after the law change live in about two minutes, once the demo's owner has saved that backup; `./demo.sh backup original` puts the original app back.

A screen recording of a good rehearsal of each section makes a further fallback, if you choose to make one.

## Shallow and Deep Versions

Shallow, for a short slot or a non-technical audience: the scene, the law, then straight to the changed app running from `./demo.sh backup new-law`, with no agent on screen.

Deep, for a technical audience: as above, plus opening the repository in an editor after the new law to walk through Cosine's code changes, the migration and the checks.
