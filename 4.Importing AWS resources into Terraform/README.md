# Importing AWS Resources into Terraform

This project demonstrates how to import an existing AWS EC2 instance into Terraform state so the resource can be managed through IaC without recreating it.

## Overview

Sometimes infrastructure already exists in AWS and must be brought under Terraform control. The `import` block allows Terraform to connect an existing resource to a declared Terraform resource. This project shows the basic pattern for an EC2 instance import.

## Infrastructure Managed

- Existing EC2 instance imported into Terraform
- AWS provider configuration for the target region
- Resource declaration matching the existing instance

## Files Included

- `main.tf` — import block and EC2 resource definition
- `provider.tf` — AWS provider settings
- `variables.tf` — region configuration

## Import Pattern

The `import` block maps an existing instance ID to the Terraform resource:

```hcl
import {
  to = aws_instance.server
  identity = {
    id = "i-01e3a6e0e9a052ca9"
  }
}
```

This is useful when a resource already exists and you want to bring it under Terraform management without manual recreation.

## Key Points

- Existing AWS resources can be imported into Terraform state
- The resource configuration in Terraform must match the real infrastructure as closely as possible
- Import is useful for migration, modernization, and gradual IaC adoption

## Usage

```bash
terraform init
terraform plan
terraform import aws_instance.server <instance-id>
```

If using the `import` block in configuration, Terraform can incorporate the import directly during the standard workflow.

## Notes

This project is a practical example of migrating an existing AWS resource into a controlled Terraform environment while preserving the current live infrastructure.
