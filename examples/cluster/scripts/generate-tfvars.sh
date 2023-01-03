#!/bin/bash

EKS_NAME="atlas-test"

eks_oidc_id=$(eksctl get cluster -n $EKS_NAME -ojson | jq -r '.[].Identity.Oidc.Issuer' | sed -e 's/^https:\/\///g')
aws_vpc_id=$(eksctl get cluster -n $EKS_NAME -ojson | jq -r '.[].ResourcesVpcConfig.VpcId')
aws_subnet_ids="[$(eksctl get cluster -n $EKS_NAME -ojson | jq '.[].ResourcesVpcConfig.SubnetIds | .[length -1, length -2, length -3]' | paste -sd, - | sed 's/\"/\\"/g')]"
aws_security_group_ids=$(eksctl get cluster -n $EKS_NAME -ojson | jq -r '.[].ResourcesVpcConfig.ClusterSecurityGroupId')

cat .tfvars.template > ./test.tfvars
sed -i "s|<ORG_ID>|$ORG_ID|" ./test.tfvars
sed -i "s|<eks_oidc_id>|$eks_oidc_id|" ./test.tfvars
sed -i "s|<aws_vpc_id>|$aws_vpc_id|" ./test.tfvars
sed -i "s|<aws_subnet_ids>|$aws_subnet_ids|" ./test.tfvars
sed -i "s|<aws_security_group_ids>|$aws_security_group_ids|" ./test.tfvars