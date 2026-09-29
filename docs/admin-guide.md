# Admin Guide

Status: draft, 29 September 2026. For Seb: the one-off and occasional steps behind the demo, which presenters never do. Presenters follow the install guide and the demo guide only.

## Put the Workflows in Place

The demo command, `demo.sh`, sits at the top of the repository and must stay executable, which Git records; presenters get it when they download the demo.


The build workflows live in `.github/workflows`. Cowork sessions can write there by moving a file in with the shell on the Mac, though not with their file-copying tool; they then commit it. A workflow started by the demo command must be on main on GitHub before it can be started on any branch, so push after any workflow change.

## Let GitHub Start and Stop the Azure App

The demo command starts and stops the hosted app through the 'Azure app' workflow, so presenters never need the Azure portal or an Azure account. GitHub needs its own sign-in to Azure for this, limited to the one web app. Once only:

You need to be an Owner of the subscription (or hold User Access Administrator), and be allowed to register applications in your directory, which a personal Azure account normally is.

1. Sign in at https://portal.azure.com and open Cloud Shell (the terminal icon at the top of the page), choosing Bash. The first time, it asks about storage; choosing no storage account is fine.
2. Get the web app's full ID. `joint-keepers` appears twice below: first the web app's name, then its resource group. Change either if yours differ:

        az webapp show --name joint-keepers --resource-group joint-keepers --query id -o tsv

3. Create a sign-in for GitHub that can manage only that app, pasting the ID from step 2:

        az ad sp create-for-rbac --name joint-keepers-github --role "Website Contributor" --scopes "PASTE-THE-ID-HERE" --json-auth

4. Copy everything it prints, from the opening brace to the closing brace. It contains a password; treat it as one.
5. In GitHub, open the repository, then Settings, Secrets and variables, Actions. On the Secrets tab, add a secret named `AZURE_CREDENTIALS` with the copied text as its value. On the Variables tab, add a variable named `AZURE_RESOURCE_GROUP` with the resource group's name, `joint-keepers`.
6. Test it from the repository's Actions tab: choose 'Azure app', Run workflow, action 'start'. It should end by printing the app's state as Running and its address. Then run it again with action 'stop', because the app is deliberately insecure and must not be left running.

The password this creates expires, by default after a year. When it does, the Azure app workflow fails at 'Sign in to Azure'; repeat steps 3 to 5, which replaces it.

While the app is stopped, any build that tries to put it on Azure fails at its last check, because the stopped app does not answer. That includes a push to main that changes the app. The demo command starts the app first when it needs to; for a push of your own, start the app first.

The Website Contributor role gives GitHub full control of this one web app, including its settings and deployments, but nothing else in the subscription. The deploy step in the legacy workflow uses a separate credential, the publish profile, set up in the Azure setup guide.

## Give a Presenter Access

In the repository on GitHub, open Settings, then Collaborators, select Add people, and enter the presenter's GitHub username or email. They get write permission, which lets them send branches and start builds. They must accept the invitation, which expires after seven days, before the demo command works for them. `./demo.sh check` tells them if they have not.

Presenters need nothing on Azure.

## Choose a Checkpoint

`./demo.sh jump hop1` puts the app as it is after hop 1 on Azure, from a Git tag named `checkpoint/hop1`. The tag does not exist until you choose which run is the reference.

A jump builds with the workflow as it is in the tagged commit, so the checkpoint must sit on top of the current main, not on the branch Cosine's run was made on. To make it from Cosine's passing run (4236345, on try/cosine-2), replay that change onto main and tag the result:

    git switch main
    git pull
    git switch -c checkpoint-hop1
    git cherry-pick 4236345
    git tag checkpoint/hop1
    git push origin checkpoint/hop1
    git switch main

If the workflows or the demo command change later, make the checkpoint again the same way, moving the tag with `git tag -f checkpoint/hop1` and `git push -f origin checkpoint/hop1`. Pushing the tag starts one extra build, which checks but does not deploy; that is expected.

## Tidy Up Old Demo Branches

Every run of the demo leaves a branch on GitHub named `demo/live-...` or `demo/jump-...`. They do no harm. To remove them, delete them from the Branches page of the repository on GitHub.

## Sources

- Creating a service principal for GitHub with the Azure CLI, and the azure/login action's creds input: https://github.com/Azure/login and https://learn.microsoft.com/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac, checked 29 September 2026
- Starting and stopping a web app with the Azure CLI: https://learn.microsoft.com/en-us/cli/azure/webapp#az-webapp-start, checked 29 September 2026
- Website Contributor role: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/web-and-mobile, checked 29 September 2026
- GitHub collaborators: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/inviting-collaborators-to-a-personal-repository, checked 29 September 2026
- Starting a workflow on another branch needs the workflow on the default branch: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow, checked 29 September 2026
