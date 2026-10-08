# Terraform Remote State

This project focuses on Terraform state management and the concept of remote state storage. It creates an Amazon S3 bucket configured for state persistence and versioning, preparing the environment for centralized infrastructure tracking.


## Overview

Terraform stores resource metadata in a state file. This project configures an S3 bucket to host that information and enables versioning so state history is preserved. The example also includes the common remote backend pattern, although it is commented in the provider configuration for flexibility.

## Infrastructure Deployed

- Amazon S3 bucket
- S3 bucket versioning
- AWS provider configuration
- Terraform backend configuration placeholder for remote state

## Files Included

- `main.tf` — S3 bucket and versioning configuration
- `variables.tf` — bucket name, region, and tags
- `provider.tf` — AWS provider and backend setup
- `output.tf` — bucket metadata output

## Key Configuration

The bucket is configured with:

- `force_destroy = true`
- Versioning enabled to support state recovery and auditability
- Tag metadata for environment and ownership information

## Purpose

This project introduces the best practice of storing Terraform state remotely instead of locally, which helps with:

- Collaboration across teams
- Safer state management
- Tracking infrastructure history
- Reduced risk of local state loss

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To switch to a true remote backend, uncomment the S3 backend block and provide the target bucket, key, and AWS region.

## Notes

This project is a foundational example for centralized state management in Terraform and is a key step before adopting larger multi-user or enterprise infrastructure workflows.
