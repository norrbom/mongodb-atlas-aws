# The Repository 
This repository contains a Terraform module that aims to simplify management MongoDB Atlas in AWS by providing an additional abstraction layer on top of the official modules from AWS and MongoDB. The module comes with some opinionated settings for running Atlas.

Cluster resources are however managed outside the module, since there is little gain in creating an additional abstraction layers.

## Examples
- [atlas-privatelink](examples/atlas-privatelink): How to set up a one-way VPC Endpoint connection aka. Private Link to Atlas. The example shows how to use IAM roles for service accounts in EKS for passwordless authentication.

# Build and test and release
Development is driven through the the examples. Stable versions of the module are consumed from main branch, git tags are used for versioning.

## Prerequisites
- an Atlas account
- an AWS account
## Contribute
- clone this repo or pull the latest changes
- create a new branch features/<feature>
- make changes and test them using an example implementation
- push the code and create a pull request to main branch
- get the pull request reviewed and approved, the branch should be removed once merged.
- create a new git tag version, following semantic versioning praxis MAJOR.MINOR.PATCH