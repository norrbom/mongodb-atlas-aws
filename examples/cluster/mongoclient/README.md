# How to connect to the Atlas cluster from a Pod in EKS

## Preparations

Set up a Atlas cluster and a EKS cluster by following the guide: [examples/atlas-privatelink](../README.md)

## Get the kubconfig and store it in the default location

```bash
make write-kubeconfig
```

## Build the mongoclient Docker image and push to ECR

```bash
AWS_REGION=eu-north-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
docker build -t mongoclient .
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr create-repository --region $AWS_REGION --repository-name mongoclient || true
docker tag mongoclient $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mongoclient:latest
docker push  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mongoclient:latest
```

## Create a Kubernetes service account annotated with the AWS IAM role

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
CLIENT_NAMESPACE=test
SERVICE_ACCOUNT=test-client
ATLAS_IAM_ROLE_ARN=<<<Get IAM role arn from Atlas or AWS>>>
kubectl create namespace $CLIENT_NAMESPACE
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: $ATLAS_IAM_ROLE_ARN
  name: $SERVICE_ACCOUNT 
  namespace: $CLIENT_NAMESPACE
EOF
```

## Deploy the mongodb client Pod using the Service Account

```bash
AWS_REGION=eu-central-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
CLIENT_NAMESPACE=test
SERVICE_ACCOUNT=test-client
IMG_DIGEST=$(aws ecr describe-images --region $AWS_REGION --repository-name mongoclient --image-ids imageTag=latest | jq -r '.imageDetails[0].imageDigest')
cat <<EOF | kubectl -n $CLIENT_NAMESPACE apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mongoclient
  labels:
    app: mongoclient
spec:
  serviceAccountName: $SERVICE_ACCOUNT
  containers:
  - image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mongoclient@$IMG_DIGEST
    command:
      - "sleep"
      - "604800"
    imagePullPolicy: Always
    name: mongoclient
  restartPolicy: Always
EOF
```

## Run the python client, it should output a list of databases

Get the connection string

```bash
terraform -chdir=../ output -json connection_strings | jq -r 'keys[] as $k | .[$k][0].aws_private_link_srv'
```

Test the connection
```bash
CLIENT_NAMESPACE=test
kubectl exec -it -n $CLIENT_NAMESPACE mongoclient -- python /app/client.py --test --host <xxx.mongodb.net>
```

## Connect using mongosh

```bash
kubectl exec -it -n $CLIENT_NAMESPACE mongoclient -- /bin/bash
eval $(python /app/client.py --mongosh)
```