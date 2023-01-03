SHELL := bash

INSTANCE_TYPES ?= "t3.small"
AWS_REGION     ?= "eu-central-1"
ORG_ID         ?= "6299ad37ac40fa3c6b424acc"

create-eks: eksctl generate-tfvars

eksctl:
	@if [ "$(ORG_ID)" == "" ]; then echo "Atlas organization ID (ORG_ID) is required as ENV, try: export ORG_ID=<ORG_ID>"; \
	else \
		echo -e "Atlas organization ID: $(ORG_ID)"; \
		eksctl create cluster --node-private-networking --name=atlas-test --with-oidc --vpc-cidr=192.168.200.0/24 --region=$(AWS_REGION) --instance-types=$(INSTANCE_TYPES) --nodes=1 --dry-run > cluster.yaml; \
		eksctl create cluster -f cluster.yaml; \
	fi

generate-tfvars:
	$(shell AWS_DEFAULT_REGION=$(AWS_REGION) ORG_ID=$(ORG_ID) sh scripts/generate-tfvars.sh)

write-kubeconfig:
	eksctl utils write-kubeconfig --cluster=atlas-test

cleanup:
	eksctl delete cluster -f cluster.yaml