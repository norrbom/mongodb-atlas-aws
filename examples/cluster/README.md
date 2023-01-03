# About the example

This example demonstrates how to:

* Set up a AWS PrivateLink Connection to MongoDB Atlas from an existing VPC
* Fetch MongoDB Atlas API keys from AWS Secrets Manager with terraform
* Set up a dedicated MongoDB Atlas cluster
* Use AWS IAM for passwordless authentication, [README.md](./mongoclient/README.md)

## Prerequisites

* Terraform
* An MongoDB Atlas account with an organization
* An AWS account and credentials with permission to read and write to IAM resources
* Security groups allowing access to Atlas, see: [www.mongodb.com/docs/atlas/security-private-endpoint/#make-sure-that-your-security-groups-are-configured-properly](https://www.mongodb.com/docs/atlas/security-private-endpoint/#make-sure-that-your-security-groups-are-configured-properly)

This examples uses a remote backend for managing terraform state.

## Preparations

### Create Atlas API Key

Log in to Atlas UI and create a API key with Organization Project Creator permissions, upload the public and private Atlas API keys in AWS Secret Manager

```bash
aws secretsmanager create-secret --name "ATLAS-PROJ-CREATE-API-KEYS" --secret-string '{"public_key":"******","private_key":"******************"}'
```

If your organization settings requires, add a list of IP addressees that need access to the Atlas API to the Key API access list.

### Create a VPC and a minimal EKS cluster

_Skip this section if you want to use an existing VPC, the EKS cluster is only necessary in order to set up passwordless authentication_

* download the eksctl CLI tool: https://eksctl.io/
* create a EKS cluster in a new VPC

Set the Atlas organization ID, you can find it in the Altas UI under Organization settings.

```bash
export ORG_ID=6299ad37ac40fa3c6b424acc
make create-eks
```

## Provision AWS and Atlas resources with Terraform

### initialize to download modules and provider plugins

```bash
terraform init
```

### Run the plan, review it, execute the plan and destroy resources when your done

```bash
terraform plan -var-file="test.tfvars"
terraform apply -var-file="test.tfvars"
```

## Connect to the Atlas cluster from a Pod in EKS

[How to connect to the Atlas cluster from a Pod in EKS](mongoclient/README.md)

## Cleanup

### Delete all resources

```bash
terraform destroy -var-file="test.tfvars"
make cleanup
```

## Atlas AWS KMS Customer Managed Keys

### Key rotation

Atlas rotates the master data keys every 90 days automatically.<br>
The AWS KMS customer master key can be configured to be auto rotated.<br>
_When you enable automatic key rotation for a KMS key, AWS KMS generates new cryptographic material for the KMS key every year. AWS KMS saves all previous versions of the cryptographic material in perpetuity so you can decrypt any data encrypted with that KMS key._<br>
Since the Id of the key will be intact, a new version of the key does not require any change in the Atlas Encryption at Rest project settings.<br>
https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html

### Manually rotate the AWS KMS key

In case a AWS KMS CMK key become exposed, you need to rotate the key manually.<br>
**_Deleting a key will render any backup using that key useless!_**<br>
https://www.mongodb.com/docs/atlas/security-aws-kms/#rotate-your-aws-customer-master-key

### Restore a AWS KMS key

AWS KMS keys can be restored in case they have been unintentionally deleted.