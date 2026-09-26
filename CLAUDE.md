# Joint Keepers

This repository is one of the two homes of the Joint Keepers project. The other is the vault folder `Big Trouble Labs/Cosine Demos/Joint Keepers` in Seb's megavault. Before doing anything, read the readme at the root of that folder, then its state document and its latest session log. The readme holds the session procedures, and it wins over anything written here.

## Which Home Wins

The repository is authoritative for what is built. The vault is authoritative for intent: why the demo is designed as it is, what has been decided and what is still open. When they disagree about what exists, the repository wins. When they disagree about intent, the vault wins. Either way the gap is a defect to be fixed. Nothing else is a source: not claude.ai project documents, assistant memory, chat history or anything an earlier session wrote.

## Git

The rules are in the Working With Git section of the vault readme, and are read before any Git command. In short: never write the GitHub token (kept in `.github-token`, which is git-ignored) into the Git configuration, a remote address, a log, a commit or the chat; get delete permission on this folder before any Git command that writes, and remove any lock files it leaves; pull with rebase before pushing; never force push; stop and ask Seb if a rebase conflicts. Commits made by Cosine during a rehearsal or a demo run are never rewritten, squashed or pushed without Seb's say-so, because checkpoints are taken from them.

## What Sessions Will Not Do

Build, write files or change anything until Seb says 'crack on'. Delete anything other than Git's own lock files. Present an assumption as a decision.
