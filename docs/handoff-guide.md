# Joint Keepers Handoff Guide

This guide sets up a complete, independent copy of the Joint Keepers demo under your own GitHub account and your own Microsoft Azure subscription, and then runs it. The demo comes to you as a zip file of the repository. Your copy starts from it, with a history of its own, and nothing in it depends on, or connects to, anywhere else. Follow the parts in order. Each part ends with a check, so you know it worked before you move on.

## Licence

Copyright © 2026 the copyright holder. All rights reserved, except as granted below.

The copyright holder grants Cosine, and its employees, contractors and agents, a perpetual, irrevocable, worldwide, royalty-free, non-exclusive licence to use, run, copy, modify, adapt, distribute, sublicense and otherwise exploit this demo and everything in it, including for commercial purposes, without restriction and without any obligation to the copyright holder. The demo is provided as is, without warranty of any kind.

The same statement is in the repository's README.

## What the Demo Is

Joint Keepers is a 10 to 12 minute live demo of an AI coding agent, Cosine, changing a legacy government system. The system is a fictional livestock registration service called 'Register livestock', badged only 'UK Government Demo Service'. It is an old-style Microsoft app: VB.NET (Visual Basic .NET) Web Forms on the .NET Framework 4.8, with a SQLite database, and it only runs on Windows.

The demo has two stages:

1. The new law. A fictional law, the Livestock Keeping (Joint Keepers) Regulations 2026, lets an animal have up to four keepers. On stage, the presenter points Cosine at a written brief, and Cosine changes the old code and the database to comply. GitHub then builds the changed app on a Windows machine, proves that nothing else changed, and puts it on a public web address for the audience.
2. Modernisation. Cosine rewrites the changed app in modern technology without changing its behaviour. This stage is not built yet; the demo guide marks where it will go.

How the proof works: before any change, a 'golden master' recorded exactly what the old app shows in twelve everyday scenarios. After Cosine's change, the build replays those scenarios and compares the screens, checks the database migration kept every keeper, and checks six scenarios written from the law against approved results. Any difference fails the build.

## How the Pieces Fit

- Your GitHub repository holds the code, the demo command and two workflows (automated jobs GitHub runs). 'Legacy app' builds the old app on GitHub's Windows machines, runs every check, and deploys to Azure. 'Azure app' starts and stops the hosted app.
- Your Azure web app, on the free tier, is where the audience clicks round the app. GitHub deploys to it; nobody deploys by hand.
- Each presenter's Mac runs only Git, GitHub's command line tool and Cosine. It never builds or checks anything itself.
- The demo command, `./demo.sh`, is all a presenter types, apart from one line typed into Cosine.

## What You Need

- A GitHub account, or an organisation you can create repositories in.
- An Azure subscription in which you are an Owner (or hold the User Access Administrator or Role Based Access Control Administrator role), and in which you may register applications. A personal account normally qualifies. If you have none, create one at https://azure.microsoft.com/free; a card is needed for identity checks. The free tier of Azure App Service costs nothing.
- A Mac with an Apple silicon chip (M1 or later). Part 1 sets it up.
- Cosine CLI, with an account to sign in with, and the model you intend to present with.
- The zip file of the demo you were given, called ZIP_FILE in this guide. It contains the whole repository, including hidden folders such as `.github`, and no history.
- About two hours for the whole set-up, most of it waiting for builds.

Throughout, replace words in capitals, such as YOUR_ACCOUNT, with your own values. Commands are typed or pasted into the Terminal app exactly as shown.

## Part 1: Set Up Your Mac

Every presenter's Mac needs this too (Part 8). Do it on your own Mac now, because Part 2 commits and pushes from it.

1. Git. In Terminal, type `git --version`. If macOS offers to install the command line developer tools, accept and wait for it to finish.
2. Git's name and email, which Git records on every change. Use the private 'noreply' address shown in GitHub under Settings, then Emails; it looks like `12345678+yourname@users.noreply.github.com`. If you use your own email instead, and GitHub is set to keep it private and to block command line pushes that expose it, GitHub refuses your pushes.

        git config --global user.name "YOUR NAME"
        git config --global user.email "YOUR_NOREPLY_ADDRESS"

3. GitHub's command line tool, `gh`. Download the file ending `_macOS_universal.pkg` from https://github.com/cli/cli/releases/latest and open it. macOS may block it at first because it is unsigned; if so, open System Settings, then Privacy & Security, select Open Anyway, and run it again. Then sign in:

        gh auth login

   Choose GitHub.com, then HTTPS, then yes to 'Authenticate Git with your GitHub credentials?', then 'Login with a web browser'. Press Enter to open the browser and paste the one-time code shown. Answering yes to Git matters: it lets Git push, including the workflow files in Part 2.
4. Cosine. Install it with `curl -fsSL https://cosine.sh/install | bash`. The script may ask for your Mac's password (nothing appears as you type); if it ends by telling you to open a new terminal, close Terminal and open it again. Sign in with `cos login`, and set Cosine to the model you will present with. Every presenter should use the same Cosine version and model as were used in rehearsal, or rehearsal results tell you little.

Check: `git --version`, `gh auth status` and `cos --version` each answer without an error.

## Part 2: Make Your Own Copy

This makes a new repository whose history starts with a single fresh commit of the zip's contents.

1. In GitHub, select the + menu at the top right, then New repository. Choose your account or organisation as the owner, name it `joint-keepers`, and choose Private or Public (see the note below). Leave it empty: no README, no .gitignore, no licence. Select Create repository.
2. On your Mac, in Terminal:

        cd ~
        unzip PATH_TO_ZIP_FILE
        cd joint-keepers
        chmod +x demo.sh
        git init -b main
        git add -A
        git commit -m "Joint Keepers demo"
        git remote add origin https://github.com/YOUR_ACCOUNT/joint-keepers.git
        git push -u origin main

   For PATH_TO_ZIP_FILE, you can type `unzip ` with a space and then drag ZIP_FILE from Finder into the Terminal window. The zip makes a folder called joint-keepers in your home folder. Unzip it in Terminal as shown rather than by double-clicking, so the hidden folders come out reliably. `chmod +x demo.sh` makes sure the demo command can be run; Git records that, so everyone who clones your repository gets it.

Private or public: either works. In a private repository, GitHub's included build minutes apply (2,000 a month on the Free plan), and Windows machines cost more per minute than Linux ones; each full build takes two to three minutes. If your account has a spending limit of zero, builds stop when the included minutes run out. In a public repository, build minutes on standard machines are free, but anyone can read the code and the build logs, which include the hosted app's address.

Check: your repository on GitHub shows the files. The Actions tab should show a run of 'Legacy app' starting from your push; if none appears within a minute, start one yourself: select 'Legacy app', then Run workflow on branch main. Go on to Part 3 while it runs.

## Part 3: Check the First Build

With no Azure settings yet, the 'Legacy app' workflow builds and checks the original app and skips the deploy.

1. Open the Actions tab and select the 'Legacy app' run.
2. Wait for it to finish, about two minutes.

Check: the run shows a green tick. The steps 'Deploy the legacy app to Azure App Service' and 'Check the hosted app' show as skipped, which is expected until Part 5.

If a step was refused as not allowed, an organisation policy is restricting which actions can run. Under Settings, Actions, General, choose 'Allow all actions and reusable workflows', or ask your organisation's administrator to allow actions/checkout, actions/upload-artifact, azure/login and azure/webapps-deploy. If no run appears at all, GitHub Actions is switched off on that same page.

## Part 4: Create the Azure Web App

1. Sign in at https://portal.azure.com.
2. Select Create a resource, then Web App.
3. On the Basics tab:
   - Resource group: Create new, named `joint-keepers`.
   - Name: any name Azure accepts, for example `joint-keepers-demo`. Note it: this is APP_NAME.
   - Publish: Code.
   - Runtime stack: ASP.NET V4.8.
   - Operating System: Windows.
   - Region: UK West. If Azure refuses the free tier for lack of quota, choose another region, such as North Europe or West Europe.
   - Pricing plan: create a new plan and choose Free F1.
4. On the Deployment tab:
   - Continuous deployment: Disable. If it is enabled, Azure writes its own workflow into your repository.
   - Basic authentication: Enable. The deploy uses a publish profile, which needs it.
5. Select Review + create, then Create. When it finishes, select Go to resource.
6. In the app's menu, open Configuration (or Settings, Configuration), then General settings. Make sure 'SCM Basic Auth Publishing Credentials' is On, and save if you changed it.
7. Under Environment variables, make sure there is no setting called `WEBSITE_RUN_FROM_PACKAGE`. If there is, delete it: it makes the app's files read-only, and the app could not write to its database.
8. On the Overview page, copy the Default domain, which looks like `joint-keepers-demo-abc123.ukwest-01.azurewebsites.net`. The app's address, APP_URL, is `https://` followed by that domain and a closing `/`.

Check: the Overview page shows the app as Running, and APP_URL opens a default Azure holding page.

## Part 5: Connect GitHub to Azure

GitHub needs two things from Azure: a publish profile, to deploy the app, and its own sign-in, to start and stop the app. Neither is ever given to presenters.

### The Publish Profile

1. On the web app's Overview page, select Download publish profile. The file is a password for deploying to the app; treat it as one.
2. In your GitHub repository, open Settings, then Secrets and variables, then Actions.
3. On the Secrets tab, select New repository secret. Name: `AZURE_WEBAPP_PUBLISH_PROFILE`. Value: the whole contents of the downloaded file. Save it.
4. Delete the downloaded file from your Mac.

### GitHub's Sign-In to Azure

This creates a service principal: an Azure account for a program rather than a person. It is limited to the one web app.

1. In the Azure portal, open Cloud Shell (the terminal icon in the bar at the top) and choose Bash. The first time, it asks about storage: choose 'No storage account required', pick your subscription, and apply.
2. Get the web app's full identifier, replacing APP_NAME:

        APP_ID=$(az webapp show --name APP_NAME --resource-group joint-keepers --query id -o tsv); echo $APP_ID

   It prints a long line starting `/subscriptions/`.
3. Create the sign-in:

        az ad sp create-for-rbac --name joint-keepers-github --role "Website Contributor" --scopes "$APP_ID" --json-auth

4. It prints a block of text between `{` and `}`, containing a password. Copy all of it, from the opening brace to the closing brace. Cloud Shell may also print a warning that the `--json-auth` option is deprecated; it still works, and the warning is not part of the block to copy.
5. Back in GitHub's Secrets and variables, Actions page, on the Secrets tab, add a secret named `AZURE_CREDENTIALS` with the copied block as its value.

The Website Contributor role gives this sign-in full control of the one web app, including its settings and deployments, but nothing else in the subscription. Its password expires after one year by default. When it does, the 'Azure app' workflow fails at 'Sign in to Azure'; repeat steps 2 to 5 in a new Cloud Shell session, which issues a new password, and replace the secret.

If step 3 refuses with a permissions error, your Azure account lacks a role that can assign roles on the app (Owner, User Access Administrator or Role Based Access Control Administrator), or may not register applications in your directory. Ask your Azure administrator for one of those roles, or to run step 3 for you.

### The Variables

On the Variables tab of the same page, add three repository variables:

| Name | Value |
| --- | --- |
| `AZURE_WEBAPP_NAME` | APP_NAME |
| `AZURE_WEBAPP_URL` | APP_URL, starting `https://` and ending `/` |
| `AZURE_RESOURCE_GROUP` | `joint-keepers` |

Check: the Secrets tab lists `AZURE_WEBAPP_PUBLISH_PROFILE` and `AZURE_CREDENTIALS`; the Variables tab lists the three variables.

## Part 6: Prove the Whole Chain

1. In the Actions tab, select 'Azure app', then Run workflow, choose action 'start', and run it. It should finish in under a minute with a green tick; its Report step prints 'App state: Running' and the app's address.
2. Select 'Legacy app', then Run workflow on branch main. This time the deploy runs. Wait for the green tick, about two minutes.
3. Open APP_URL. You should see 'Register livestock' with a list of six holdings. Open a holding, then an animal: the original app shows a single Keeper line.
4. Run 'Azure app' again with action 'stop'. Opening APP_URL now shows Azure's 'stopped' page.

Check: all three runs are green and the app behaved as described. The app is now stopped, which is how it should be left: it is deliberately insecure (see Part 12).

## Part 7: Add Presenters

Each presenter needs their own GitHub account with permission to change the repository, because the demo sends Cosine's change to GitHub to be built.

- Personal account: in the repository, open Settings, then Collaborators (under Access), select Add people, and enter their username or email. Collaborators on a personal repository can push to it.
- Organisation: open Settings, then 'Collaborators & teams' (under Access), select Add people (or Add teams), and choose the Write role.

They must accept the invitation, which expires after seven days. Presenters can push and start builds, and the demo command reads the repository variables for them. They cannot read the secrets' values, but anyone with write access can replace secrets and variables, or change a workflow on a demo branch, so add only people you trust. They need nothing in Azure. To remove someone, use the same page.

## Part 8: Set Up Each Presenter's Mac

Each presenter does Part 1 on their own Mac. The same steps, with more detail, are in `docs/install-guide.md`. Then:

    git clone https://github.com/YOUR_ACCOUNT/joint-keepers.git
    cd joint-keepers
    ./demo.sh check

Check: every line of `./demo.sh check` says 'ok' and it ends 'This Mac is ready.' A line marked PROBLEM names a step in `docs/install-guide.md`: its step 1 is Part 1 steps 1 and 2 here, its step 2 is Part 1 step 3, and its step 3 is Part 1 step 4. A line saying your account cannot send changes means the invitation in Part 7 has not been accepted.

Do the same on your own Mac, in the copy from Part 2 or a fresh clone.

## Part 9: The Demo Command

Run from Terminal in the joint-keepers folder.

| Command | When | What it does |
| --- | --- | --- |
| `./demo.sh check` | Once, after setting up the Mac | Checks Git, your name and email, GitHub sign-in and write access, and Cosine. Changes nothing. |
| `./demo.sh start` | Before each demo or rehearsal | Gets the latest code, starts the Azure app, puts the original app on it with a fresh database, and starts a fresh branch for the run. About three minutes. Ends by printing the app's address and the line to type into Cosine. |
| `./demo.sh publish` | When Cosine has finished | Saves Cosine's change, sends it to GitHub, follows the build and its checks, and puts the changed app live. About two minutes. If the build fails, it says so and opens the fallback screenshots. |
| `./demo.sh backup original` | If things go wrong | Puts the original app live. About two minutes. |
| `./demo.sh backup new-law` | If things go wrong | Puts a saved, known-good version of the app after the new law live. About two minutes. Needs the backup saved in Part 10. |
| `./demo.sh finish` | After each demo or rehearsal | Stops the Azure app. |

`start` and `finish` set aside any uncommitted changes left from an earlier run rather than deleting them; `git stash list` shows them.

## Part 10: Rehearse and Save Your Backup

The new-law backup is a version of the changed app taken from one of your own passing rehearsals. `./demo.sh backup new-law` puts it live if a live run goes wrong.

1. Rehearse once, on a presenter's Mac:

        ./demo.sh start

   Start Cosine in the same folder and type exactly:

        Carry out the brief in prompts/new-law.md

   When Cosine has finished:

        ./demo.sh publish

2. If `publish` reports that all checks passed, open the app's address, open an animal, and add a second keeper. Note the branch name `start` printed, which looks like `demo/live-0110-091530`. This is BRANCH below. If `publish` failed, run `./demo.sh finish` and rehearse again; Cosine's output varies between runs.
3. Save the backup from that branch. On any Mac with your copy:

        git fetch origin
        git switch main
        git pull
        git switch -c checkpoint-new-law
        git cherry-pick origin/main..origin/BRANCH
        git tag checkpoint/new-law
        git push origin checkpoint/new-law
        git switch main

   This replays Cosine's passing change on top of the current main, so the backup builds with the current workflows, and labels it `checkpoint/new-law`. Pushing the tag starts one extra build, which checks but does not deploy; it should pass.
4. Test it: `./demo.sh backup new-law`, then `./demo.sh finish`.

Keep the `demo/live-...` branch the backup came from. If you later change the workflows or the demo command, save the backup again from it: run `git branch -D checkpoint-new-law`, then repeat step 3 with `git tag -f checkpoint/new-law` and `git push -f origin checkpoint/new-law`.

Rehearse until the new-law stage passes reliably inside its time slot. A useful bar is nine passes in ten. Record each result.

If your Cosine set-up keeps memories between sessions, clear them before each rehearsal and each demo, so every run starts the same.

## Part 11: Run the Demo

The full script, with what to show and say in each section, is `docs/demo-guide.md`. The running order:

| Time | Section |
| --- | --- |
| 0:00 to 1:30 | The scene: the old service and its planted flaws |
| 1:30 to 2:30 | The safety net: the golden master, and what it cannot see |
| 2:30 to 6:00 | The new law, in the old code: Cosine at work |
| 6:00 to 7:00 | Proof after the new law: the build, the checks, the changed app live |
| 7:00 to 10:00 | Modernise (not built yet) |
| 10:00 to 11:00 | Proof after modernising (not built yet) |
| 11:00 to 12:00 | Close |

The presenter's steps:

1. About ten minutes before: `./demo.sh start`. Open the address it prints.
2. At the new law: start Cosine and type `Carry out the brief in prompts/new-law.md`.
3. When Cosine has finished: `./demo.sh publish`. When it passes, refresh the app, open an animal and add a second keeper.
4. If `publish` fails: show the screenshots it opens, which are in `demo/screens/joint-keepers`, and say 'let me show you the one we ran earlier'. If there is time, run `./demo.sh backup new-law` and show the working app about two minutes later. Never debug live.
5. Afterwards: `./demo.sh finish`.

The law itself, which the presenter shows on screen, is Part A of `docs/joint-keepers-law.md`. The brief Cosine reads is `prompts/new-law.md`.

## Part 12: Keep It Safe and Running

- The hosted app is deliberately insecure: it is open to SQL injection (database commands typed into its forms) and shows full error pages, because those are among the planted flaws. Keep it stopped except around demos and rehearsals, which `./demo.sh finish` does. It has no sign-in in front of it.
- While the app is stopped, any build that tries to deploy fails, at the deploy step or at its last check. The demo command starts the app first when it needs to. If you push a change to main yourself, start the app first with the 'Azure app' workflow, or include `[skip ci]` in the commit message to skip the build.
- Only one Azure app exists, so only one demo can run at a time. Two presenters running at once overwrite each other's app. For parallel demos, make a second repository and Azure app by repeating this guide.
- The free tier allows 60 minutes of processor time a day and sleeps after 20 minutes without visitors. `./demo.sh start` wakes it. Move to the Basic B1 plan only if a limit is actually hit; it is charged by the second for as long as the plan exists, even while the app is stopped.
- `AZURE_CREDENTIALS` expires after a year by default; renew it as in Part 5 (steps 2 to 5 of GitHub's sign-in to Azure).
- Every run leaves a branch on GitHub named `demo/live-...` or `demo/backup-...`. They do no harm; delete them from the repository's Branches page when you like, except the one your backup came from.

## Troubleshooting

| What you see | What to do |
| --- | --- |
| The push in Part 2 is refused | Run `gh auth login` again and answer yes to signing in to Git (Part 1, step 3). Without it, GitHub refuses passwords and refuses pushes containing workflow files. |
| `./demo.sh check` says your account cannot send changes | Accept the repository invitation (Part 7), then run `gh auth login` again. |
| `zsh: permission denied: ./demo.sh` | Run `chmod +x demo.sh`, then commit and push the change so others get it. |
| `start` stops at 'Asking GitHub to start the app on Azure' | Open the failed 'Azure app' run. 'Missing:' names a secret or variable to add (Part 5). A failure at 'Sign in to Azure' means `AZURE_CREDENTIALS` is wrong or expired. |
| `start` prints an empty address, or a build passes but did not reach Azure | Check the `AZURE_WEBAPP_URL` variable (Part 5). |
| A build fails at 'Deploy the legacy app to Azure App Service' | If the app was stopped, start it with the 'Azure app' workflow and run the build again. Otherwise check `AZURE_WEBAPP_PUBLISH_PROFILE`, and that basic authentication is on (Part 4, steps 4 and 6); download a fresh publish profile and replace the secret. |
| A build fails at 'Check the hosted app' | The app was stopped or asleep, or `AZURE_WEBAPP_URL` is wrong. Start the app and run the build again. |
| `publish` fails with scenarios marked FAIL | Cosine's change did not meet the law. This is a real result, not a fault in the demo: use the fallback, and count it as a failed rehearsal. The build's 'legacy-screens' artifact shows what the app displayed. |
| `backup new-law` says the backup has not been saved | Complete Part 10, step 3. |
| GitHub refuses a push, mentioning a private email | Use your GitHub noreply address (Part 1, step 2), then amend the commit with `git commit --amend --reset-author --no-edit` and push again. |

## What Is in the Repository

- `legacy/RegisterLivestock`: the old app, with its flaws left in on purpose.
- `db`: the database structure, invented seed data and the pristine database. Every build starts from the pristine copy.
- `golden`: the golden master scenarios, the runner, the recorded results of the original app, and the approved results after the new law.
- `prompts/new-law.md`: the brief Cosine is pointed at.
- `demo.sh`: the demo command.
- `demo/screens`: screenshots of the original app and of the app after the new law, used as fallbacks.
- `.github/workflows`: the 'Legacy app' and 'Azure app' workflows.
- `tools`: the build's checks and the migration tools.
- `docs`: the demo guide (the script), the law, the install guide for presenters, the admin guide, the golden master explanation, the Azure set-up notes, and this guide.
- `AGENTS.md`: standing notes that Cosine reads in this repository, including what it must not change.

Everything in the service is fictional: no real department, no crown, no GOV.UK logo, and fictional legislation, labelled as fictional on screen. Keep it that way, so the demo can never be mistaken for a real government service.
