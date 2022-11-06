## About
This example demonstrates how to:

* Set up a AWS PrivateLink Connection to MongoDB Atlas from an existing VPC
* Fetch MongoDB Atlas API keys from AWS Secrets Manager with terraform
* Set up a dedicated MongoDB Atlas cluster
* Use AWS IAM for passwordless authentication, [README.md](/examples/atlas-privatelink/mongoclient/README.md)

## Prerequisites
* Terraform
* An MongoDB Atlas account with an organization
* An AWS account, this examples uses a remote backend for managing terraform state to enable team collaboration on the same resources
* Security groups allowing access to Atlas, see: https://www.mongodb.com/docs/atlas/security-private-endpoint/#make-sure-that-your-security-groups-are-configured-properly

## Preparations

### Set AWS credentials
```bash
export AWS_ACCESS_KEY_ID="xxxx"
export AWS_SECRET_ACCESS_KEY="xxxx"
export AWS_SESSION_TOKEN="xxxx"
```
### Create Atlas API Key
Log in to Atlas UI and create API keys with Organization Owner permissions, upload the public and private Atlas API keys in AWS Secret Manager
```bash
aws secretsmanager create-secret --name "ATLAS-ORGANISATION-API-KEYS" --secret-string '{"public_key":"**********","private_key":"**********"}'
```

### Create a VPC and a minimal EKS cluster
_Skip this section if you want to use an existing VPC, the EKS cluster is only necessary in order to set up passwordless authentication_
* download the eksctl CLI tool: https://eksctl.io/
* create a EKS cluster in a new VPC
```bash
eksctl create cluster --name=atlas-test --with-oidc --vpc-cidr=192.168.200.0/24 --instance-types=t4g.nano --nodes=1 --dry-run > cluster.yaml
eksctl create cluster -f cluster.yaml
export TF_VAR_OIDC_ID=$(eksctl get cluster -n atlas-test -ojson | jq -r '.[].Identity.Oidc.Issuer' | sed -e 's/^https:\/\///g')
export TF_VAR_VPC_ID=$(eksctl get cluster -n atlas-test -ojson | jq -r '.[].ResourcesVpcConfig.VpcId')
export TF_VAR_SG_IDS=$(eksctl get cluster -n atlas-test -ojson | jq -r '.[].ResourcesVpcConfig.SecurityGroupIds' | sed ':a;N;$!ba;s/[\n ]*//g')
export TF_VAR_SUBNET_IDS="[$(eksctl get cluster -n atlas-test -ojson | jq '.[].ResourcesVpcConfig.SubnetIds | .[length -1, length -2, length -3]' | paste -sd, -)]"
```
### Generate locals.tf
Set the Atlas organization ID, you can find it in the Altas UI under Organization settings.
```bash
export TF_VAR_ATLAS_ORG_ID=<xxxxx>
```
Generate locals.tf with VPC and EKS details<br>
_Set TF_VAR* variables or edit the file manually if you did not create a eks cluster with eksctl in the previous section_
```bash
cat <<EOF >locals.tf
locals {
  org_id                 = "$TF_VAR_ATLAS_ORG_ID"
  owner                  = "test-team"
  project_name           = "TEST"
  cloud_provider         = "AWS"
  cloud_region           = "EU_NORTH_1"
  cluster_name           = "test"
  eks_oidc_id            = "$TF_VAR_OIDC_ID"
  aws_vpc_id             = "$TF_VAR_VPC_ID"
  aws_subnet_ids         = $TF_VAR_SUBNET_IDS # list of subnets Ids
  aws_security_group_ids = $TF_VAR_SG_IDS     # list of security group Ids
}
EOF
```
This command will delete the EKS cluster and related resources when its not needed anymore
```bash
eksctl delete cluster -f cluster.yaml
```
## Provision AWS and Atlas resources with Terraform

### initialize to download modules and provider plugins
```bash
terraform init
```
### Run the plan, review it, execute the plan and destroy resources when your done
```bash
terraform plan
terraform apply
terraform destroy
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