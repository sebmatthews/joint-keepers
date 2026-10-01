# Joint Keepers

A repeatable live demo of AI-augmented code generation, run through Cosine CLI (Cosine's command line coding agent). The agent changes a legacy government system to meet a change in legislation, and every change is proved against the old system's recorded behaviour.

The service in the demo, 'Register livestock', is fictional. It is badged only as a UK Government demo service, does not represent any real department or system, and the legislation it implements is invented for the demo.

The demo runs for about ten minutes. Presenters run it with one command, `./demo.sh`, and the script is in `docs/demo-guide.md`. Future expansion: the same foundation supports a modernisation stage, in which the agent rewrites the changed service in modern technology and the same golden master proves the behaviour is unchanged.

## What Is Here

- `legacy/RegisterLivestock`: the legacy app, VB.NET Web Forms on the .NET Framework, with its flaws left in on purpose
- `db`: the database structure, the invented seed data and the pristine database
- `golden`: the golden master scenarios (including the joint keepers scenarios), the runner, the recorded results of the original app, and the approved results after the new law (`golden/results-new-law`)
- `demo/screens/legacy`: screenshots of the legacy app, taken on GitHub's Windows build machine
- `demo/screens/joint-keepers`: screenshots of the legacy app after the joint keepers change, from Cosine's passing run of the new-law brief
- `demo.sh`: the demo command presenters run: `./demo.sh check`, `start`, `publish`, `backup` and `finish`
- `.github/workflows`: the legacy app's build, and the workflow that starts and stops the Azure app
- `docs`: the joint keepers law, the install guide and demo guide for presenters, the admin guide, the handoff guide for setting up an independent copy, the golden master approach and the Azure setup
- `prompts`: the briefs given to the coding agent
- `AGENTS.md`: standing notes for any coding agent working in the repository
- `tools`: the build's checks, the migration tools, and the script that fetches results and screenshots from GitHub

## Copyright and Licence

Copyright © 2026 the copyright holder. All rights reserved, except as granted below.

The copyright holder grants Cosine, and its employees, contractors and agents, a perpetual, irrevocable, worldwide, royalty-free, non-exclusive licence to use, run, copy, modify, adapt, distribute, sublicense and otherwise exploit this demo and everything in it, including for commercial purposes, without restriction and without any obligation to the copyright holder. The demo is provided as is, without warranty of any kind.
