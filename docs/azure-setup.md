# Azure Setup for the Hosted Legacy App

Status: trial, 27 September 2026. This puts the legacy app on Azure App Service's free tier so an audience can click round it, and tests whether that works. Seb does these steps; the workflow does the rest. Portal steps checked against Microsoft's documentation on 27 September 2026; the portal changes often, so labels may differ slightly.

## 1. Create the Web App

1. Sign in at https://portal.azure.com. If you have no Azure account, create a free one first at https://azure.microsoft.com/en-gb/free.
2. Select **Create a resource**, then **Web App**.
3. On the **Basics** tab:
   - **Resource group**: create a new one called `joint-keepers`.
   - **Name**: `joint-keepers-demo`, or any name Azure accepts. Note it down.
   - **Publish**: Code.
   - **Runtime stack**: ASP.NET V4.8.
   - **Operating System**: Windows.
   - **Region**: UK West. UK South refused the free tier on 27 September 2026 with 'Operation cannot be completed without additional quota' (F1 limit 0); UK West worked. If UK West refuses too, try North Europe or West Europe.
   - **Pricing plan**: create a new plan and choose **Free F1**.
4. On the **Deployment** tab:
   - **Continuous deployment**: leave it **disabled**. If it is enabled, Azure writes its own workflow file into the repository.
   - **Basic authentication**: **Enable**. The deployment uses a publish profile, which needs it. New apps have it off by default.
5. Select **Review + create**, then **Create**, and wait for it to finish. Select **Go to resource**.

## 2. Check Two Settings

1. In the app's menu, open **Configuration**, then **General settings**. If the portal has moved it, search the app's menu for 'SCM Basic Auth'.
2. **SCM Basic Auth Publishing Credentials** must be **On**. Save if you changed it.
3. Under **Environment variables** (or **Configuration**, **Application settings**), make sure there is no setting called `WEBSITE_RUN_FROM_PACKAGE`. If it exists, the app's files are read-only and it cannot write to its database.

## 3. Give GitHub What It Needs

1. On the app's **Overview** page, select **Download publish profile**. This file is a password for deploying to the app; treat it as one.
2. Also on **Overview**, copy the **Default domain**. It looks like `joint-keepers-demo-abc123.ukwest-01.azurewebsites.net`.
3. In GitHub, open the repository, then **Settings**, **Secrets and variables**, **Actions**.
4. On the **Secrets** tab, select **New repository secret**. Name: `AZURE_WEBAPP_PUBLISH_PROFILE`. Value: paste the whole contents of the downloaded file.
5. On the **Variables** tab, add two repository variables:
   - `AZURE_WEBAPP_NAME`: the app's name from step 1.
   - `AZURE_WEBAPP_URL`: `https://` followed by the default domain, ending with `/`.
6. Delete the downloaded publish profile file from your Mac.

## 4. What Happens Next

On the next push, after the legacy app passes its checks on the Windows build machine, the workflow deploys it to the web app with a fresh copy of the database, then checks the live address: that the holdings list loads (the SQLite library works in Azure), that registering an animal works and is still there when the page is reloaded (the database can be written to), and how long building plus deploying took. The results are in the run's 'hosted-check' step and its 'hosted-screens' files.

Until the secret and variables exist, the workflow skips the Azure steps and behaves as before.

## Costs

The free tier costs nothing, but allows only 60 minutes of processing a day, is 32-bit only, and puts the app to sleep after 20 minutes without visitors, so the first page after a pause is slow. For a real demo, switch the plan to Basic B1 (about £0.07 an hour in UK South, charged for the hours it exists; the UK West price is not checked) beforehand and back to Free afterwards. Confirmed from Microsoft's App Service limits and UK South prices, checked 27 September 2026.

## Sources

- Create a web app: https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore (ASP.NET V4.8, Free F1, and the note that new apps disable basic authentication)
- Basic authentication setting: https://learn.microsoft.com/en-us/azure/app-service/configure-basic-auth-disable
- Publish profile and GitHub secret: https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions
- Limits and prices: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits and https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/
