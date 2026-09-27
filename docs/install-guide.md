# Install Guide

Status: draft, 27 September 2026. Written for presenters setting up a Mac to run the Joint Keepers demo. Parts of the demo are not built yet; those steps are marked. Facts about outside products are labelled confirmed (with where and when they were checked), or unconfirmed.

## What You Need

A Mac with an Apple silicon chip (M1 or later), an internet connection for the setup, and about 45 minutes. You do not need to be an engineer. Every command below is typed, or pasted, into the Terminal app exactly as shown.

You do not need Windows. The old version of the app only runs on Windows, so it is built and run on GitHub's own Windows machines, and the demo shows real screenshots taken there.

## Step 1: Install Git

Open Terminal and type `git --version`. If macOS offers to install the 'command line developer tools', accept, and wait for it to finish. Git is how you download the demo.

## Step 2: Install .NET 10

.NET is Microsoft's free toolkit for building and running the modern version of the app. Download and run the Mac installer for Apple silicon from Microsoft's .NET 10 download page, https://dotnet.microsoft.com/en-us/download/dotnet/10.0. Choose the SDK (software development kit), not the runtime.

Check it worked: `dotnet --version` should print a number starting 10.

Confirmed: .NET 10 is the current Long Term Support ('LTS') release, supported until 14 November 2028; SDK 10.0.401 was released on 8 September 2026 (dotnet.microsoft.com, checked 27 September 2026).

## Step 3: Install Node.js 24 and Google Chrome

Node.js runs the golden master check, which proves the modern app behaves exactly like the old one. Download and run the macOS installer for the version marked LTS from https://nodejs.org/en/download.

Check it worked: `node --version` should print a number starting v24.

The check drives Google Chrome, so install Chrome from https://www.google.com/chrome if it is not already on the Mac.

Confirmed: Node.js 24 is the Active LTS line (nodejs.org, checked 27 September 2026).

## Step 4: Install and Sign In to Cosine CLI

Cosine CLI is the AI coding agent the audience watches. Install it with this command:

    curl -fsSL https://cosine.sh/install | bash

Check it worked: `cos --version` should print a version number. Then sign in with `cos login`, which opens a browser page to sign in to your Cosine account and then returns you to Terminal.

Confirmed: the install command, `cos --version` and `cos login` (cosine.sh/docs/cli/install-and-authenticate-the-cli, checked 27 September 2026). Cosine also lists installing through Homebrew; this guide does not assume Homebrew. Unconfirmed: Cosine's minimum macOS version, and whether its install script is supported on macOS as well as Linux (its quickstart page lists it under Linux only). To be checked on a clean Mac.

## Step 5: Set Up the Model Cosine Uses

Not decided yet. Every presenter must use exactly the same model setup that was used in rehearsal, or the rehearsal results mean little. Which setup that is will be written here once rehearsals start.

For reference, if the setup is a Claude subscription: Cosine can use a Claude Pro, Max, Team or Enterprise plan. You install Claude Code, run `claude` once and sign in, then start Cosine with `cos`, type `/model` and choose one of the 'Claude Subscription' models. Confirmed (cosine.sh/docs/cli/login-with-claude and code.claude.com/docs/en/setup, checked 27 September 2026).

## Step 6: Download the Demo

In Terminal:

    git clone https://github.com/sebmatthews/joint-keepers.git
    cd joint-keepers/golden
    npm ci

The last command downloads the small tool the golden master check uses.

## Step 7: Check Everything Is Ready

Not built yet. A single demo command will check that everything above is installed and signed in, and that the demo is at its starting point. Until then, run each of these and check the result:

    git --version
    dotnet --version
    node --version
    cos --version

## If Something Goes Wrong

Write down the exact message Terminal shows and send it to Seb. Do not try other commands you find online; the demo depends on every Mac being set up the same way.

## Where These Facts Come From

- .NET support policy and downloads: https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core and https://dotnet.microsoft.com/en-us/download/dotnet/10.0, checked 27 September 2026
- Node.js releases: https://nodejs.org/en/about/previous-releases, checked 27 September 2026
- Cosine CLI install and sign-in: https://cosine.sh/docs/cli/install-and-authenticate-the-cli and https://cosine.sh/cli, checked 27 September 2026
- Cosine with a Claude subscription: https://cosine.sh/docs/cli/login-with-claude, checked 27 September 2026
- Claude Code setup: https://code.claude.com/docs/en/setup, checked 27 September 2026
