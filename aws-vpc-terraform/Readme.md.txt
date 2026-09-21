# 🌐 AWS VPC Networking with Terraform (IaC)

Infrastructure as Code (IaC) using **Terraform** to provision an **AWS VPC** with public and private subnets, an Internet Gateway, a NAT Gateway, route tables, security groups, and two EC2 instances (one public and one private).

---

## 📐 Architecture

```
                          Internet
                             │
                    ┌────────▼────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│ VPC  172.17.0.0/16         │                                 │
│                            │                                 │
│   ┌────────────────────────▼───────────────────────────┐     │
│   │ Public Route Table (0.0.0.0/0 → IGW)               │     │
│   └───────┬─────────────────────────────┬──────────────┘     │
│           │                             │                    │
│  ┌────────▼──────────┐        ┌─────────▼─────────┐          │
│  │ Public Subnet 1   │        │ Public Subnet 2   │          │
│  │ 172.17.0.0/24     │        │ 172.17.2.0/24     │          │
│  │                   │        │                   │          │
│  │  Public EC2       │        │  NAT Gateway      │          │
│  │  (t3.micro)       │        │  + Elastic IP     │          │
│  └────────┬──────────┘        └─────────▲─────────┘          │
│           │ SSH                         │                    │
│           │                             │                    │
│   ┌───────┴─────────────────────────────┴──────────────┐     │
│   │ Private Route Table (0.0.0.0/0 → NAT Gateway)      │     │
│   └────────────────────────┬───────────────────────────┘     │
│                            │                                 │
│                   ┌────────▼──────────┐                      │
│                   │ Private Subnet 1  │                      │
│                   │ 172.17.1.0/24     │                      │
│                   │                   │                      │
│                   │  Private EC2      │                      │
│                   │  (t3.micro)       │                      │
│                   └───────────────────┘                      │
└──────────────────────────────────────────────────────────────┘
```

---

## 📦 Resources Created

| Resource | Name | Description |
|---|---|---|
| `aws_vpc` | `ashelga_vpc` | VPC `172.17.0.0/16` with DNS support and hostnames enabled |
| `aws_internet_gateway` | `ashelga_igw` | Internet access for the public subnets |
| `aws_subnet` | `ashelga_sub_public_1` | Public subnet `172.17.0.0/24` |
| `aws_subnet` | `ashelga_sub_public_2` | Public subnet `172.17.2.0/24` (hosts the NAT Gateway) |
| `aws_subnet` | `ashelga_sub_private_1` | Private subnet `172.17.1.0/24` |
| `aws_eip` | `ashelga_nat_gateway_eip` | Elastic IP for the NAT Gateway |
| `aws_nat_gateway` | `ashelga_nat_gateway` | Outbound internet access for private instances |
| `aws_route_table` | `public_rt` / `private_rt` | Public and private route tables |
| `aws_route_table_association` | — | Associates each subnet with its route table |
| `aws_security_group` | `ashelga_public_ec2-sg` | SSH allowed from anywhere (`0.0.0.0/0`) |
| `aws_security_group` | `ashelga_private_ec2-sg` | SSH allowed only from within the VPC (`172.17.0.0/16`) |
| `aws_instance` | `ashelga-ec2-public` | EC2 in the public subnet (Amazon Linux 2023) |
| `aws_instance` | `ashelga-ec2-private` | EC2 in the private subnet (Amazon Linux 2023) |

The AMI is looked up automatically with `data "aws_ami"`, always using the most recent **Amazon Linux 2023** image.

---

## ✅ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.5`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured (`aws configure`)
- An AWS account with permissions to create VPC, EC2, EIP, and NAT Gateway resources
- An existing **Key Pair** in AWS (used by the private instance)

---

## ⚙️ Variables

| Variable | Type | Description | Example |
|---|---|---|---|
| `aws_region` | `string` | AWS region | `us-east-1` |
| `az_zone` | `string` | Availability Zone | `us-east-1a` |
| `aws_key_pair` | `string` | Name of an existing Key Pair | `my-key` |

Example `terraform.tfvars` file:

```hcl
aws_region   = "us-east-1"
az_zone      = "us-east-1a"
aws_key_pair = "my-key"
```

---

## 🚀 Usage

```bash
# 1. Clone the repository
git clone https://github.com/Mmiguel08/AWS-VPC-NETWORKING---TERRAFORM-IaC.git
cd AWS-VPC-NETWORKING---TERRAFORM-IaC

# 2. Initialize Terraform
terraform init

# 3. Format and validate the code
terraform fmt
terraform validate

# 4. Review the execution plan
terraform plan

# 5. Apply the infrastructure
terraform apply
```

To tear everything down when you're done:

```bash
terraform destroy
```

---

## 🔑 Accessing the Private Instance

The private instance has no public IP. To reach it, connect to the public instance first and then hop to the private one (bastion / jump host pattern).

Using **SSH Agent Forwarding**:

```bash
# Add your key to the SSH agent
ssh-add my-key.pem

# Connect to the public instance with agent forwarding
ssh -A ec2-user@<PUBLIC_EC2_PUBLIC_IP>

# From the public instance, connect to the private one
ssh ec2-user@<PRIVATE_EC2_PRIVATE_IP>
```

Or in a single command using **ProxyJump**:

```bash
ssh -J ec2-user@<PUBLIC_IP> ec2-user@<PRIVATE_IP> -i my-key.pem
```

> ⚠️ **Note:** in the current code, the public instance **does not define `key_name`**. Add `key_name = var.aws_key_pair` to `aws_instance.ashelga_ec2_public`, otherwise you won't be able to SSH into it.

---

## 💰 Costs

Some resources **incur charges** even with minimal usage:

- **NAT Gateway**: billed hourly plus data processed
- **Elastic IP**: billed when not associated with a running resource
- **EC2 t3.micro**: may be covered by the Free Tier (check your account)

Remember to run `terraform destroy` when you finish testing.

---

## 🔒 Best Practices & Suggested Improvements

- Restrict SSH on the public security group to **your own IP** instead of `0.0.0.0/0`
- Spread subnets across **multiple Availability Zones** for high availability
- Use **AWS Systems Manager Session Manager** instead of SSH
- Store the Terraform state in a **remote backend** (S3 + DynamoDB)
- Split the code into separate files (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`)
- Add `outputs` (VPC ID, instance IPs, etc.)

---

## 📁 Suggested Project Structure

```
.
├── main.tf            # Main resources
├── variables.tf       # Variable declarations
├── providers.tf       # AWS provider configuration
└── README.md
```

---

## 🛠️ Technologies

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)

---

## 👤 Author

Made by **Moises Miguel**
[GitHub](https://github.com/Mmiguel08) • [LinkedIn](https://www.linkedin.com/in/moisesmiguel08)

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.