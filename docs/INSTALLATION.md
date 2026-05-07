# Installation Guide

## 1. Import the Egg

1. Download the `egg.json` from the root of this repository.
2. Log into your Pterodactyl admin control panel.
3. Navigate to **Nests** in the sidebar.
4. Click **Import Egg** at the top right.
5. Select the downloaded `egg.json` file.
6. Select the appropriate Nest (e.g., Generic or a custom nest).
7. Click **Import**.

## 2. Create the Server

1. Navigate to **Servers** and click **Create New**.
2. Assign a name, owner, and node.
3. Set your resource limits (Recommended: 4GB RAM minimum for Kasm).
4. Under **Nest Configuration**, select the nest where you imported the Kasm egg.
5. Setup the required Startup Variables:
   - **Server Port**: Usually `443` or `8443` (Make sure your node has this port allocated)
   - **Public Hostname**: The domain or IP you will use to access Kasm.
6. Click **Create Server**.

## 3. Initial Startup

1. Go to the server console.
2. Click **Start**.
3. Watch the console output. The first start will take some time as it initializes the Kasm database and configuration.
4. Kasm passwords will be synchronized automatically. Check the **Startup** tab in your Pterodactyl Panel's server view for the automatically generated **Admin Password** and **User Password** variables. Save these!

## 4. Access Kasm

1. Navigate to `https://<your-public-hostname>:<server-port>` in your web browser.
2. Accept the self-signed SSL certificate warning (you can configure valid certificates later).
3. Log in with the credentials generated during startup.
