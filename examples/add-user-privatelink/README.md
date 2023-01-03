# About the example

This example demonstrates how to from another codebase:

* Create connect additional VPC Endpoints to an existing Private Link in Atlas.
* Add additional IAM users in a existing Atlas project

## Prerequisites

* An Atlas project with an existing Private Link
* An AWS account and credentials that can read and write to IAM resources

This examples uses a remote backend for managing terraform state.

## Preparations

### Create Atlas API Key

Log in to Atlas UI and create a API key with Organization Project Creator permissions, upload the public and private Atlas API keys in AWS Secret Manager

```bash
aws secretsmanager create-secret --name "ATLAS-PROJ-CREATE-API-KEYS" --secret-string '{"public_key":"******","private_key":"******************"}'
```

If your organization settings requires, add a list of IP addressees that need access to the Atlas API to the Key API access list.

## Provision AWS and Atlas resources with Terraform

Get projectID and PrivateLink ID from the [cluster](../cluster) example

```bash
terraform -chdir=../cluster output -json atlas_project_id | jq -r
terraform -chdir=../cluster output -json private_links | jq -r
```

### initialize to download modules and provider plugins

```bash
terraform init
```

### Run the plan, review it, execute the plan and destroy resources when your done

```bash
terraform plan -var-file="integration.tfvars"
terraform apply -var-file="integration.tfvars"
```