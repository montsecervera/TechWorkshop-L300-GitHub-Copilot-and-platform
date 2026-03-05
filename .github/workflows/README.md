# GitHub Actions quickstart (App Service container deploy)

This repo includes `.github/workflows/build-and-deploy-appservice-container.yml`.

## 1) Configure required GitHub secret

Create this repository secret:

- `AZURE_CREDENTIALS`: JSON output from `az ad sp create-for-rbac --name <sp-name> --sdk-auth`

The service principal should have at least:

- `Contributor` on the App Service resource group
- `AcrPush` on your Azure Container Registry

## 2) Configure required GitHub variables

Create these repository variables:

- `AZURE_CONTAINER_REGISTRY_NAME` (example: `myacrname`)
- `AZURE_APP_SERVICE_NAME` (example: `my-webapp-name`)
- `AZURE_RESOURCE_GROUP_NAME` (example: `my-rg`)

## 3) Run the workflow

- Push to `main`, or
- Run **Build and Deploy Container to Azure App Service** manually from the Actions tab.

The workflow builds a container image, pushes it to ACR, and updates the App Service container image to that new tag.