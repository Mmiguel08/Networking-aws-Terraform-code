# Building Reusable Terraform Modules

This project shows how to encapsulate reusable AWS infrastructure logic into a Terraform module. It demonstrates a modular approach for building EC2 instances with validation rules, dynamic AMI lookup, and consistent tagging.


## Overview

Instead of repeating resource blocks, this project defines a reusable module under `module/ec2`. The module accepts variables for:

- Instance type
- Operating system image
- Tagging metadata

This promotes reusability, maintainability, and cleaner infrastructure design.

## Infrastructure Deployed

- EC2 instance created through a reusable module
- Dynamic AMI selection for Ubuntu or Amazon Linux
- Tag validation ensuring required metadata is present
- AWS provider configuration for the target region

## Module Definition

The module contains:

- `main.tf` — EC2 resource definition and AMI data sources
- `variables.tf` — validated inputs for instance type, image OS, and tags

## Key Features

- Validates accepted instance types: `t2.micro` and `t3.micro`
- Validates accepted OS values: `ubuntu` and `amazon linux`
- Requires a `BusinessUnit` tag in the tagging map
- Automatically selects the latest supported AMI for the chosen operating system

## Files Included

- `main.tf` — root module call to the EC2 module
- `provider.tf` — AWS provider configuration
- `variables.tf` — region definition
- `module/ec2/main.tf` — reusable EC2 resource logic
- `module/ec2/variables.tf` — module input validation

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

This project highlights the value of Terraform modules for scaling infrastructure across multiple environments while keeping the code consistent, readable, and easier to maintain.
