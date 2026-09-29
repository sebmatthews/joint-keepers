# Install Guide

Status: draft, 29 September 2026. Written for presenters setting up a Mac to run the Joint Keepers demo. In the demo, an AI coding agent first changes the old version of the app to meet a new law (hop 1), then modernises it (hop 2). Parts of the demo are not built yet, and some choices are not made yet; those steps are marked. Facts about outside products are labelled confirmed (with where and when they were checked), or unconfirmed.

## What You Need

A Mac with an Apple silicon chip (M1 or later), an internet connection for the setup, and about an hour. You do not need to be an engineer. Every command below is typed, or pasted, into the Terminal app exactly as shown.

Two accounts, which Seb sets up access to before you start:

1. A GitHub account. GitHub is the website that holds the demo's code and runs its checks. Seb adds your account to the demo's repository (its shared folder of code) with permission to change it, because during the demo you send the agent's change to GitHub to be built and checked. GitHub emails you an invitation; accept it.
2. Access to the demo's web app in Microsoft Azure, the cloud service where the audience can click round the app. Seb invites you; accept the invitation email. You use it to start the app before a demo and stop it afterwards.

You do not need Windows. The old version of the app only runs on Windows, so it is built and run on GitHub's own Windows machines, and the demo shows real screenshots taken there.

## Step 1: Install Git

Open Terminal and type `git --version`. If macOS offers to install the 'command line developer tools', accept, and wait for it to finish. Git is how you download the demo and send changes back.

Then tell Git your name and email, which it records against every change you make. Use the private 'noreply' address GitHub gives your account, shown in GitHub under Settings, then Emails; it looks like `12345678+yourname@users.noreply.github.com`. If you use your own email instead and GitHub is set to keep it private, GitHub refuses your changes when you send them.

    git config --global user.name "Your Name"
    git config --global user.email "you@example.com"

## Step 2: Install the GitHub Command Line Tool and Sign In

The GitHub command line tool, called `gh`, lets Terminal talk to GitHub: to sign you in, and to start and watch the demo's builds. Download the macOS installer from https://github.com/cli/cli/releases/latest: under Assets, the file whose name ends `_macOS_universal.pkg`. Open it. macOS may refuse to open it at first, because GitHub does not sign it; if so, open System Settings, then Privacy & Security, scroll down, select Open Anyway, and run it again.

Check it worked: `gh --version` should print a version number.

Then sign in:

    gh auth login

Answer its questions: choose GitHub.com, then HTTPS, then yes to signing in to Git with your GitHub credentials, then logging in with a web browser. It shows a one-time code; press Enter to open GitHub in your browser, and paste the code there. This also lets Git send changes to GitHub without asking for a password each time.

Check it worked: `gh auth status` should say you are logged in to github.com.

## Step 3: Install .NET 10, Node.js 24 and Google Chrome

These three are for hop 2, the modernisation, which is not built yet. Hop 1 does not use them on your Mac: its checks all run on GitHub's machines. Whether hop 2's checks run on your Mac or on GitHub is not decided yet, so install them for now; if they turn out not to be needed, this step will be removed.

.NET is Microsoft's free toolkit for building and running the modern version of the app. Download and run the Mac installer for Apple silicon from Microsoft's .NET 10 download page, https://dotnet.microsoft.com/en-us/download/dotnet/10.0. Choose the SDK (software development kit), not the runtime. Check it worked: `dotnet --version` should print a number starting 10.

Node.js runs the golden master check, which proves the app still behaves exactly as recorded. Download and run the macOS installer for version 24 from https://nodejs.org/en/download, choosing v24 in the version list. Use version 24 even after a newer one is marked LTS (expected on 28 October 2026), so every Mac is the same. Check it worked: `node --version` should print a number starting v24.

The check drives Google Chrome, so install Chrome from https://www.google.com/chrome if it is not already on the Mac.

Confirmed: .NET 10 is the current Long Term Support ('LTS') release, supported until 14 November 2028; SDK 10.0.401 was released on 8 September 2026 (dotnet.microsoft.com, checked 27 September 2026, and Microsoft's release data, checked 29 September 2026). Node.js 24 is the Active LTS line until 20 October 2026, then in maintenance; Node.js 26 is scheduled to become LTS on 28 October 2026 (Node.js release schedule, checked 29 September 2026).

## Step 4: Install and Sign In to Cosine CLI

Cosine CLI is the AI coding agent the audience watches.

Not decided yet: which version of Cosine presenters use. Cosine has provided a MacBook with its own build, called `cos2`, which is the one the demo has been tested with so far. The public version, called `cos`, is described below. Until this is settled with Cosine, check with Seb before installing.

The public version installs with this command:

    curl -fsSL https://cosine.sh/install | bash

The script may ask for your Mac's password; type it and press Enter (nothing appears as you type). If it finishes by telling you to open a new terminal, close Terminal and open it again. Then check it worked: `cos --version` should print a version number. Then sign in with `cos login`, which opens a browser page to sign in to your Cosine account and then returns you to Terminal.

Confirmed: the install command, `cos --version` and `cos login` (cosine.sh/docs/cli/install-and-authenticate-the-cli, checked 27 September 2026). Cosine also lists installing through Homebrew; this guide does not assume Homebrew. Cosine's documentation lists the install script under Linux only, but the script itself installs the Apple silicon Mac version and refuses Intel Macs (script read 29 September 2026). Unconfirmed: Cosine's minimum macOS version. To be checked on a clean Mac.

## Step 5: Set Up the Model Cosine Uses

Not decided yet. Every presenter must use exactly the same model setup that was used in rehearsal, or the rehearsal results mean little. Which setup that is will be written here once rehearsals start.

For reference, if the setup is a Claude subscription: Cosine can use a Claude Pro, Max, Team or Enterprise plan. You install Claude Code, run `claude` once and sign in, then start Cosine with `cos`, type `/model` and choose one of the 'Claude Subscription' models. Confirmed (cosine.sh/docs/cli/login-with-claude and code.claude.com/docs/en/setup, checked 27 September 2026).

## Step 6: Download the Demo

In Terminal:

    git clone https://github.com/sebmatthews/joint-keepers.git
    cd joint-keepers/golden
    npm ci

The last command downloads the small tool the golden master check uses. It needs Node.js from step 3.

## Step 7: Check You Can Reach the Azure App

Sign in at https://portal.azure.com with the account Seb invited. Search for 'joint-keepers' at the top of the page and open the web app of that name. On its Overview page you should see Start and Stop buttons and a Default domain, which is the address the audience uses. Leave the app as you find it.

If the search finds nothing and you already had your own Azure account, you are probably looking at your own directory. Select the settings (gear) icon at the top, then Directories + subscriptions, and select Switch next to Seb's directory.

## Step 8: Check Everything Is Ready

Not built yet. A single demo command will check that everything above is installed and signed in, and that the demo is at its starting point. Until then, run each of these and check the result:

    git --version
    gh auth status
    dotnet --version
    node --version
    cos --version

## Giving a Presenter Access (Seb)

GitHub: in the repository on GitHub, open Settings, then Collaborators, select Add people, and enter the presenter's GitHub username or email. They get write permission, which lets them push branches. They must accept the invitation before they can push.

Azure: in the portal, open the joint-keepers web app, then Access control (IAM), select Add, then Add role assignment. Choose the Website Contributor role, then select the presenter as a member. If they are not already in your Azure directory, invite them first as a guest user from Microsoft Entra ID, Users, New user, Invite external user, and they accept the invitation email. Website Contributor gives them full control of this one web app, including its settings, deploying to it, downloading its publishing credentials and deleting it, but not the App Service plan or anything else in the subscription. A narrower choice is a custom role with only the permissions to read, start and stop web apps (Microsoft.Web/sites/read, Microsoft.Web/sites/start/Action and Microsoft.Web/sites/stop/Action).

## If Something Goes Wrong

Write down the exact message Terminal shows and send it to Seb. Do not try other commands you find online; the demo depends on every Mac being set up the same way.

## Where These Facts Come From

- .NET support policy and downloads: https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core and https://dotnet.microsoft.com/en-us/download/dotnet/10.0, checked 27 September 2026
- Node.js releases: https://nodejs.org/en/about/previous-releases, checked 27 September 2026
- GitHub command line tool install and sign-in: https://github.com/cli/cli/releases/latest, https://github.com/cli/cli/blob/trunk/docs/install_macos.md and https://cli.github.com/manual/gh_auth_login, checked 29 September 2026
- Node.js release schedule: https://github.com/nodejs/Release, checked 29 September 2026
- Cosine install script: https://cosine.sh/install, read 29 September 2026
- Cosine CLI install and sign-in: https://cosine.sh/docs/cli/install-and-authenticate-the-cli and https://cosine.sh/cli, checked 27 September 2026
- Cosine with a Claude subscription: https://cosine.sh/docs/cli/login-with-claude, checked 27 September 2026
- Claude Code setup: https://code.claude.com/docs/en/setup, checked 27 September 2026
- GitHub collaborators: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/inviting-collaborators-to-a-personal-repository, checked 29 September 2026
- GitHub private email and blocked pushes: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address, checked 29 September 2026
- Azure role assignment and the Website Contributor role: https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-external-users and https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/web-and-mobile, checked 29 September 2026
- Inviting a guest user: https://learn.microsoft.com/en-us/entra/external-id/b2b-quickstart-add-guest-users-portal, checked 29 September 2026
