TERRAFORM_VERSION=1.7.3
REGION=eastus

install:
	brew install tfenv 
	brew install infracost 
	brew install terraform-docs
	tfenv install $(TERRAFORM_VERSION)

workspace:
	terraform workspace new dev
	terraform workspace new qa
	terraform workspace new uat
	terraform workspace new prod
	terraform workspace select dev

backend:
	./scripts/create-tfm-backend.sh

sslcert:
	./scripts/create-self-signed-ssl.sh

sp:
	. ./scripts/create-service-principle.sh

format:
	terraform fmt

init:
	terraform init

validate:
	terraform validate

plan:
	terraform plan -var-file $(shell terraform workspace show).tfvars -out tfplan

apply:
	terraform apply tfplan

cost:
	infracost breakdown --path .

docs:	
	terraform-docs markdown ./ > docs.md
