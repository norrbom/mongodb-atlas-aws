# The Repository

This repository contains a Terraform modules that aims to simplify management MongoDB Atlas in AWS by providing an additional abstraction layer on top of the official modules from AWS and MongoDB. Some of the modules comes with opinionated settings for how to configure Atlas.

Cluster resources are however managed outside the module, since there is little gain in creating an additional abstraction layers.

## Examples

- [examples/cluster](examples/cluster): The example shows how to set up a one-way VPC Endpoint connection aka. Private Link to Atlas and how to use IAM roles for service accounts in EKS for passwordless authentication.
- [examples/add-user-privatelink](examples/add-user-privatelink): The example demonstrates how to create additional private links and users in a existing Atlas project

## Build, test and release

Development is driven through the the examples. Stable versions of the module are consumed from main branch, git tags are used for versioning.

## Prerequisites

- An Atlas account
- An AWS account

## Contribute

- clone this repo or pull the latest changes
- create a new branch features/<feature>
- make changes and test them using an example implementation
- push the code and create a pull request to main branch
- get the pull request reviewed and approved, the branch should be removed once merged.
- create a new git tag version, following semantic versioning praxis MAJOR.MINOR.PATCH