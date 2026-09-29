# Joint Keepers

A repeatable live demo of AI-augmented code generation, run through Cosine CLI (Cosine's command line coding agent). It modernises a legacy government system and then adds a feature required by a change in legislation.

The service in the demo, 'Register livestock', is fictional. It is badged only as a UK Government demo service, does not represent any real department or system, and the legislation it implements is invented for the demo.

Status: in build. The demo changes the legacy app to meet a new law (hop 1), then modernises it (hop 2). The legacy app, its database, the golden master and everything hop 1 needs are built, and hop 1 has passed its checks on an agent run. Hop 2 and the presenter tooling are not built yet.

## What Is Here

- `legacy/RegisterLivestock`: the legacy app, VB.NET Web Forms on the .NET Framework, with its flaws left in on purpose
- `db`: the database structure, the invented seed data and the pristine database
- `golden`: the golden master scenarios (including the joint keepers scenarios), the runner and the recorded results
- `demo/screens/legacy`: screenshots of the legacy app, taken on GitHub's Windows build machine
- `demo/screens/joint-keepers`: screenshots of the legacy app after the joint keepers change, from Cosine's passing run of the hop 1 prompt
- `demo.sh`: the demo command presenters run: `./demo.sh check`, `ready`, `prompt 1`, `prove`, `jump` and `reset`
- `.github/workflows`: the legacy app's build, and the workflow that starts and stops the Azure app
- `docs`: the joint keepers law, the install guide and demo guide for presenters, the admin guide, the golden master approach and the Azure setup
- `prompts`: the briefs given to the coding agent
- `AGENTS.md`: standing notes for any coding agent working in the repository
- `tools`: the build's checks, the migration tools, and the script that fetches results and screenshots from GitHub

Copyright © 2026 Seb Matthews. All rights reserved.
