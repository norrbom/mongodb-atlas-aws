# How to connect to the Atlas cluster from a Pod in EKS

## Preparations
Use the example terraform code to provision a cluster, a private link connection from a EKS cluster and a user using the *irsa_users_readonly* variable.
### User and Kubernetes Pod settings
Set AWS account ID, IAM role arn
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export ATLAS_IAM_ROLE_ARN=$(terraform output -json mongodbatlas_database_users | jq -r '.[].username | select(test("MongoDBAtlas-irsa_read-"))')
```
Set namespace and service account variables, they need to match the irsa_users_readonly values
```bash
export CLIENT_NAMESPACE=jupyterhub
export SERVICE_ACCOUNT=jupyter-atlas
```
### Store the Atlas connection string in a file that will be baked into the mongoclient Docker image
```bash
cd ../
terraform output -json cluster_srv_address > mongoclient/atlas-connection-string.txt
```
## Build the mongoclient Docker image and push to ECR
```bash
CLIENT_VERSION=0.20 # bump to new version
docker build -t mongoclient .
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com
docker tag mongoclient $AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/mongoclient:$CLIENT_VERSION
docker push  $AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/mongoclient:$CLIENT_VERSION
```
## Create a Kubernetes service account annotated with the AWS IAM role
```bash
cat <<EOF | kubectl create -f -
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
  - image: $AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/mongoclient:$CLIENT_VERSION
    command:
      - "sleep"
      - "604800"
    imagePullPolicy: Always
    name: mongoclient
  restartPolicy: Always
EOF
```
## Run the python client, it should output a list of databases
```bash
kubectl exec -it -n $CLIENT_NAMESPACE mongoclient -- python /app/client.py -t
```
## Connect with mongosh
```bash
kubectl exec -it -n rtd mongoclient -- /bin/bash
eval $(python /app/client.py -m)
```