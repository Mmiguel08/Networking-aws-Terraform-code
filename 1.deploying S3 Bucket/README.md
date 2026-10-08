# Deploying S3 Bucket

This project demonstrates how to create and configure an Amazon S3 bucket using Terraform. It focuses on infrastructure as code basics, variable-driven configuration, AWS provider setup, and resource tagging.



## Overview

The configuration provisions an S3 bucket in AWS using a Terraform resource definition and reusable variables. This lab is intended to introduce the foundations of Terraform resource creation, provider configuration, and consistent tagging for cloud resources.

## Infrastructure Deployed

- AWS S3 bucket
- AWS provider configuration for the selected region
- Input variables for bucket naming and region
- Resource tags for metadata and environment classification

## Files Included

- `main.tf` — S3 bucket resource definition
- `variables.tf` — input variables for naming, region, and tags
- `provider.tf` — AWS provider configuration
- `output.tf` — output values for bucket metadata

## Key Configuration

The S3 bucket is declared with the following characteristics:

- Unique bucket name defined by variable `s3_nucket_name`
- Region selected through variable `aws_region`
- Tag map defined through `aws_tagging`

## Example Variables

- `s3_nucket_name`: unique S3 bucket name
- `aws_region`: deployment region, default `ap-south-1`
- `aws_tagging`: metadata labels such as Team and Environment

## Outputs

The project exposes important bucket details such as:

- Bucket ID
- Bucket ARN
- Bucket domain name

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review the planned deployment:
   ```bash
   terraform plan
   ```
3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

## Notes

This is a simple introductory AWS Terraform project designed to help understand the first steps in provisioning cloud resources with code.
