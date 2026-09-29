# Install Guide

Status: draft, 29 September 2026. Written for presenters setting up a Mac to run the Joint Keepers demo. In the demo, an AI coding agent first changes the old version of the app to meet a new law, then modernises it (not built yet). Some choices are not made yet; those steps are marked. Facts about outside products are labelled confirmed (with where and when they were checked), or unconfirmed.

## What You Need

A Mac with an Apple silicon chip (M1 or later), an internet connection for the setup, and about half an hour. You do not need to be an engineer. Every command below is typed, or pasted, into the Terminal app exactly as shown.

A GitHub account. GitHub is the website that holds the demo's code and does all of its building and checking. Seb adds your account to the demo, because during the demo you send the agent's change to GitHub to be built and checked. GitHub emails you an invitation; accept it.

That is all. Your Mac does not build or check anything, and you do not need Windows or an Azure account: GitHub builds the old Windows app on its own machines, and puts it on Azure for the audience to click round.

## Step 1: Install Git

Open Terminal and type `git --version`. If macOS offers to install the 'command line developer tools', accept, and wait for it to finish. Git is how you download the demo and send changes back.

Then tell Git your name and email, which it records against every change you make. Use the private 'noreply' address GitHub gives your account, shown in GitHub under Settings, then Emails; it looks like `12345678+yourname@users.noreply.github.com`. If you use your own email instead and GitHub is set to keep it private, GitHub refuses your changes when you send them.

    git config --global user.name "Your Name"
    git config --global user.email "12345678+yourname@users.noreply.github.com"

## Step 2: Install the GitHub Command Line Tool and Sign In

The GitHub command line tool, called `gh`, lets the demo talk to GitHub from Terminal. Download the macOS installer from https://github.com/cli/cli/releases/latest: under Assets, the file whose name ends `_macOS_universal.pkg`. Open it. macOS may refuse to open it at first, because GitHub does not sign it; if so, open System Settings, then Privacy & Security, scroll down, select Open Anyway, and run it again.

Then sign in:

    gh auth login

Answer its questions: choose GitHub.com, then HTTPS, then yes to signing in to Git with your GitHub credentials, then logging in with a web browser. It shows a one-time code; press Enter to open GitHub in your browser, and paste the code there.

## Step 3: Install and Sign In to Cosine CLI

Cosine CLI is the AI coding agent the audience watches.

Not decided yet: which version of Cosine presenters use. Cosine has provided a MacBook with its own build, called `cos2`, which is the one the demo has been tested with so far. The public version, called `cos`, is described below. Until this is settled with Cosine, check with Seb before installing.

The public version installs with this command:

    curl -fsSL https://cosine.sh/install | bash

The script may ask for your Mac's password; type it and press Enter (nothing appears as you type). If it finishes by telling you to open a new terminal, close Terminal and open it again. Then sign in with `cos login`, which opens a browser page to sign in to your Cosine account and then returns you to Terminal.

Confirmed: the install command and `cos login` (cosine.sh/docs/cli/install-and-authenticate-the-cli, checked 27 September 2026). Cosine's documentation lists the install script under Linux only, but the script itself installs the Apple silicon Mac version and refuses Intel Macs (script read 29 September 2026). Unconfirmed: Cosine's minimum macOS version.

## Step 4: Set Up the Model Cosine Uses

Not decided yet. Every presenter must use exactly the same model setup that was used in rehearsal, or the rehearsal results mean little. Which setup that is will be written here once rehearsals start.

For reference, if the setup is a Claude subscription: Cosine can use a Claude Pro, Max, Team or Enterprise plan. You install Claude Code, run `claude` once and sign in, then start Cosine with `cos`, type `/model` and choose one of the 'Claude Subscription' models. Confirmed (cosine.sh/docs/cli/login-with-claude and code.claude.com/docs/en/setup, checked 27 September 2026).

## Step 5: Download the Demo

In Terminal:

    git clone https://github.com/sebmatthews/joint-keepers.git

This makes a folder called joint-keepers in your home folder. Whenever you run the demo, open Terminal and go into it first with `cd joint-keepers`.

## Step 6: Check Everything Is Ready

In the joint-keepers folder:

    ./demo.sh check

It checks each of the steps above and says 'This Mac is ready', or names the step to go back to. It changes nothing.

## If Something Goes Wrong

Write down the exact message Terminal shows and send it to Seb. Do not try other commands you find online; the demo depends on every Mac being set up the same way.

## Where These Facts Come From

- GitHub command line tool install and sign-in: https://github.com/cli/cli/releases/latest, https://github.com/cli/cli/blob/trunk/docs/install_macos.md and https://cli.github.com/manual/gh_auth_login, checked 29 September 2026
- GitHub private email and blocked pushes: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address, checked 29 September 2026
- Cosine CLI install and sign-in: https://cosine.sh/docs/cli/install-and-authenticate-the-cli and https://cosine.sh/cli, checked 27 September 2026
- Cosine install script: https://cosine.sh/install, read 29 September 2026
- Cosine with a Claude subscription: https://cosine.sh/docs/cli/login-with-claude, checked 27 September 2026
- Claude Code setup: https://code.claude.com/docs/en/setup, checked 27 September 2026
