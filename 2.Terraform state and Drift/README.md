# Terraform State and Drift

This project demonstrates how Terraform manages infrastructure state and how drift can be detected when real AWS resources differ from the configuration stored in the state file.



## Overview

The project creates a basic AWS networking and compute environment including:

- A custom VPC
- A subnet
- A security group
- An EC2 instance
- Availability zone selection based on configured values

The objective is to visualize how Terraform state tracks the deployed resources and how state drift can appear when infrastructure is modified outside Terraform.

## Infrastructure Deployed

- `aws_vpc.custom_vpc`
- `aws_subnet.main`
- `aws_security_group.example`
- `aws_vpc_security_group_ingress_rule.allow_http`
- `aws_vpc_security_group_egress_rule.allow_all_outbound`
- `aws_instance.ec2_host_1`

## Design Highlights

- Uses a custom VPC CIDR block: `10.0.0.0/16`
- Filters available AZs according to a list of desired zones
- Creates an EC2 instance using the latest Amazon Linux AMI
- Applies tags to network and compute resources

## Key Files

- `main.tf` — VPC, subnet, security group, and EC2 configuration
- `variables.tf` — AWS region, tagging, and AZ selection variables
- `provider.tf` — AWS provider setup
- `output.tf` — EC2 metadata output

## Security and Networking

The security group allows:

- Inbound HTTP traffic on port 80 from the VPC
- Outbound traffic to all destinations

This setup creates a simple environment suitable for testing Terraform state management and resource drift detection.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

After deployment, modifications made outside Terraform can be identified by comparing the actual AWS environment with the Terraform state and configuration.

## Notes

This project is especially useful for learning the difference between desired state and current state, and for understanding why drift detection is a critical part of infrastructure management.
