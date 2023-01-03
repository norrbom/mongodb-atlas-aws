# The Module

Manages systems user with with access to any database and IAM roles that allows access from a EKS cluster. Pods in the EKS cluster can assume the role via a service account, that has to be created separately.

## Assumptions

- Systems users will use passwordless authentication via AWS IAM only
- Systems users will need access to all databases in a cluster or lake
- The built in roles will be sufficient
- Users will use the Data API for access due to its granular RBAC controls and authentication providers integrations
