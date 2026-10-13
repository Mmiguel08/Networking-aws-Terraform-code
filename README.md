# Terraform AWS Labs Repository

This repository brings together a learning sequence of Terraform projects for AWS, starting with basic concepts and advancing through network patterns, private connectivity, reusable modules, and multi-VPC architecture.

## Course objective

The progression is designed to teach, in order, the essential elements of infrastructure as code:

1. basic resource creation
2. state management
3. drift and import
4. reusable modules
5. VPC networking and private connectivity
6. AWS Systems Manager (SSM) integrations
7. advanced connectivity patterns such as VPC Peering, Gateway Endpoint, Interface Endpoint, PrivateLink, and Transit Gateway

## Recommended execution order

1. 1.deploying S3 Bucket
2. 2.Terraform state and Drift
3. 3.Terraform remote State
4. 4.Importing AWS resources into Terraform
5. 5.Building reusable Terraform modules
6. 6.1.Project Building a Network and Deploying AWS Systems Manager SSM
7. 6.2.Project VPC Peering
8. 6.3.VPC Gateway endpoint for S3
9. 6.4-vpc-interface-endpoint-sqs
10. 6.5-vpc-privatelink-saas
11. 6.6-transit-gateway-three-vpcs

## Standard structure each project should follow

The clearest organization for any Terraform lab in this repository is:

```text
project-name/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── README.md
├── assets/
│   └── diagramas e imagens
├── module/
│   ├── vpc/
│   ├── ec2/
│   ├── ssm/
│   └── ...
└── .gitignore
```

### Recommended conventions

- `main.tf`: main project resources
- `provider.tf`: AWS provider and region configuration
- `variables.tf`: root module inputs
- `outputs.tf`: useful outputs for the user and other modules
- `README.md`: architecture, prerequisites, commands, and validation documentation
- `assets/`: diagrams and screenshots
- `module/`: reusable modules separated by responsibility

## Best practices observed and recommended

### 1. Separate responsibilities by module

More complex projects should divide the code into layers:

- networking (VPC, subnets, routes, gateways)
- security (security groups, IAM, policies)
- compute (EC2)
- service (S3, SQS, NLB, endpoints)
- observability and outputs

This makes maintenance and reuse easier.

### 2. Standardize names and files

The output file name should be `outputs.tf`, never `outups.tf`.

Correct example:

```hcl
output "vpc_resources" {
  value = {
    vpc_id             = aws_vpc.vpc.id
    public_subnet_ids  = aws_subnet.public[*].id
    private_subnet_ids = aws_subnet.private[*].id
  }
}
```

### 3. Configure variables and outputs explicitly

Each project should expose:

- execution region
- main network IDs
- created endpoints and resources
- SSM access commands
- relevant URLs or ARNs for validation

### 4. Prioritize private connectivity

In the most advanced labs, the correct pattern is:

- private VPC subnet without Internet Gateway/NAT
- private endpoints for SSM, S3, SQS, and PrivateLink
- access via AWS Systems Manager Session Manager, without SSH
- security through IAM, security groups, and access policies

### 5. Document practical validation

Every project README should contain:

- architecture
- prerequisites
- commands such as `terraform init`, `plan`, and `apply`
- testing steps
- connectivity or access validation
- cleanup command `terraform destroy`

## What was validated in the repository

The project set correctly demonstrates the AWS + Terraform learning path:

- basic resource provisioning (S3)
- local and remote state
- drift and import
- reusable modules
- VPC with subnets, routes, endpoints, and SSM
- VPC Peering
- Gateway Endpoint for S3
- Interface Endpoint for SQS
- PrivateLink for SaaS
- Transit Gateway with multiple VPCs

## Final recommendation

As the repository evolves, the ideal approach is to keep all projects aligned with the same documentation and naming standards, including:

- well-structured README files
- standardized file names
- clear outputs without typos
- architecture diagrams under `assets/`
- focus on real AWS practice with secure and private infrastructure

## Standard commands for use

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Note

The projects in this folder are educational and were designed to demonstrate real AWS architecture patterns. In production environments, always add:

- remote state with S3 + DynamoDB backend
- state locking
- encryption and secret management
- environment separation (`dev`, `stage`, `prod`)
- IAM policy review and least privilege
