# Joint Keepers

A repeatable live demo of AI-augmented code generation, run through Cosine CLI (Cosine's command line coding agent). It modernises a legacy government system and then adds a feature required by a change in legislation.

The service in the demo, 'Register livestock', is fictional. It is badged only as a UK Government demo service, does not represent any real department or system, and the legislation it implements is invented for the demo.

Status: in build. The legacy app, its database and the golden master recording are built. Cosine's two hops and the modern app are not.

## What Is Here

- `legacy/RegisterLivestock`: the legacy app, VB.NET Web Forms on the .NET Framework, with its flaws left in on purpose
- `db`: the database structure, the invented seed data and the pristine database
- `golden`: the golden master scenarios, the runner and the recorded results
- `demo/screens/legacy`: screenshots of the legacy app, taken on GitHub's Windows build machine
- `docs`: the install guide, the demo guide and the golden master approach
- `tools`: the phase 1 check and the script that fetches results and screenshots from GitHub

Copyright © 2026 Seb Matthews. All rights reserved.
