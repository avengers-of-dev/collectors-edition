# Introduction 
Deplyoing a managed kubernetes cluster in azure (aks). Basically what you see below. The apps / services in the cluster will be described in a later example.

![infrastructure overview](overview.png "infrastructure overview")

# If you run this regulary ...
(having this first because I need that myself a lot of times :-) )

Git clone this repo and `cd 003-terraform/01-k8s-cluster`.

If you did run this once, the following should be enough.

At the beginning we set some ENV for later commands. `APP_ID` is the ID from the service principal, `TENANT_ID` is your subscription ID at MSFT Azure and `PASSWORD` is the password of the service principal. The `ADMINUSER` is used in the terraform scripts and must be the ID of your Azure users principal ID.

```
APP_ID=
PASSWORD=
TENANT_ID=
ADMINUSER=

export TF_VAR_client_id=$APP_ID \
export TF_VAR_client_secret=$PASSWORD \
export TF_VAR_tenant_id=$TENANT_ID \
export TF_VAR_admin_client_id=$ADMINUSER

terraform plan -out out.plan
terraform apply out.plan
```

# If you run this the first time ...
(haveing this last because you basically need this once)

## create an Azure service principal for terraform

Create an Azure service principal with Azure CLI (see also [Link](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest))

```
az ad sp create-for-rbac --name svprTerraform
```

Make a note of `appId` and `password` we need that later. 

## assign roles to service principal

Set some ENV for later commands. `APP_ID` is the ID from the previous step, `TENANT_ID` is your subscription ID at MSFT Azure and `PASSWORD` is the password of the previously created service principal.

```
APP_ID=
TENANT_ID=
PASSWORD=
```

Delete reader role (in my case this was set by default) and add contributor role.

```
az role assignment delete --assignee $APP_ID --role Reader
az role assignment create --assignee $APP_ID --role Contributor
```

Test the login of the service principal

```
az login --service-principal --username $APP_ID --password $PASSWORD --tenant $TENANT_ID
```

Don't forget to re-login as user, otherwise you cannot proceed in the next step.

```
az login
az account set --subscription "Kostenstelle JJ"
```

## set up Azure storage to store Terraform state

```
az storage container create -n tfstate-devopserver --account-name stdefaultkstjj001 --account-key <YourAzureStorageAccountKey>
```

## initial configuration of azurerm backend

Initial configuration of the requested backend "azurerm". ensure to have the `main.tf` file properly set:

```
terraform {
    backend "azurerm" {
        storage_account_name = "stdefaultkstjj001"
        container_name       = "tfstate"
        resource_group_name  = "rg-default-kstjj-001"
    }
}

```

Then run:

```
terraform init -input=false
```

Afterwards go to the chapter **"If you run this regulary ...."** and continue there.

# trouble shooting

## TERRAFORM CRASH
Sometimes I got a `TERRAFORM CRASH` with `panic: runtime error: invalid memory address or nil pointer dereference` error, especially when copying templates and snippets around frtom different repos. Then a fresh start helped so far. Delete the `.terraform`folder and start over with `terraform init -input=false`.

