# Install Terraform

It is recommended to install terraform through [tfenv](https://github.com/tfutils/tfenv)

```
brew install tfenv
tfenv install latest
tfenv list
```

example output

```
tpulliam@lappy aks-terraform % tfenv list
* 1.7.3 (set by /opt/homebrew/Cellar/tfenv/3.0.0/version)
  1.3.9
  1.3.6
```

Make sure to update the `main.tf` file to use the selected Terraform version

main.tf

```
terraform {
  # Terraform version
  required_version = ">= 1.7.3"

  ...
```

# Create the Terraform Backend

Edit and run the create backend script

```
./scripts/create-tfm-backend.sh
```

Then modify `main.tf` to use the backend

```
  # Create backend using scripts/create-tfm-backend.sh
  # Then fill out the following variables
  backend "azurerm" {
    resource_group_name  = "rg-tfm-backend"
    storage_account_name = "satfmbackend12345"
    container_name       = "tfmstate"
    key                  = "terraform.tfstate"
    # Storage Account Access Key
    # Do not store in plain text!!! Export to env variable instead!!!
    # export ARM_ACCESS_KEY="my-storage-account-access-key"
    access_key = ""
  }
```

Optionally, set a terraform workspace

```
tpulliam@lappy aks-terraform % terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
tpulliam@lappy aks-terraform % terraform workspace list
  default
* dev
```

Finally, run `terraform init` to initialize the backend

# Running Terraform

Optionally, enable verbose logging:

- debug
- info
- warn
- error

```
export TF_LOG=info
terraform plan -var-file=./$(terraform workspace show).tfvars -out tfplan
terraform graph
terraform apply tfplan
```
