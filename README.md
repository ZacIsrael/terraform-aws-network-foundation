# Terraform AWS Network Foundation

A reusable Terraform module that builds a small AWS VPC network foundation across two Availability Zones. The project was created as a portfolio exercise focused on Terraform module design, network isolation, security-group references, automated plan-mode testing, deployment validation, and AWS VPC Reachability Analyzer.

## Architecture

The default configuration deploys into `us-east-1` and uses the following network layout:

| Component | Configuration |
| --- | --- |
| VPC | `10.0.0.0/16` |
| Availability Zones | `us-east-1a`, `us-east-1b` |
| Public subnet 1 | `10.0.1.0/24` in `us-east-1a` |
| Public subnet 2 | `10.0.2.0/24` in `us-east-1b` |
| Private subnet 1 | `10.0.3.0/24` in `us-east-1a` |
| Private subnet 2 | `10.0.4.0/24` in `us-east-1b` |
| Internet Gateway | Attached to the VPC |
| Route tables | Separate public and private route tables with explicit subnet associations |
| Security groups | Separate source and target security groups |
| ENIs | Source ENI in a public subnet; target ENI in a private subnet |

Subnet CIDRs are generated programmatically from the VPC CIDR with Terraform's `cidrsubnet()` function rather than being hard-coded directly into the subnet resources.

### Network Flow

```text
                           AWS VPC: 10.0.0.0/16

                 +---------------------------------------+
                 |                                       |
                 |  us-east-1a          us-east-1b       |
                 |                                       |
                 |  Public /24          Public /24       |
                 |  10.0.1.0/24         10.0.2.0/24      |
                 |      |                    |           |
                 |      +---- Public RT -----+           |
                 |                                       |
 Internet        |  Private /24         Private /24      |
 Gateway --------|  10.0.3.0/24         10.0.4.0/24      |
                 |      |                    |           |
                 |      +---- Private RT ----+           |
                 |                                       |
                 +---------------------------------------+

 Source ENI + source SG  -- TCP 443 -->  Target ENI + target SG
```

## Security Design

The project intentionally uses restrictive security controls rather than broad rules:

- The default VPC security group is not used for the source/target traffic design.
- The target security group permits inbound TCP `443` only from resources associated with the source security group.
- The source security group permits TCP `443` egress specifically to the target security group.
- No SSH (`22`) rule is configured between the source and target security groups.
- The target ingress rule does not use `0.0.0.0/0`.
- Public IPv4 assignment on the module's subnets remains disabled.
- The target ENI is placed in a private subnet and has no public IPv4 address.
- The private route table has no default route to the internet.

Security-group IDs are referenced directly for the TCP 443 rules, demonstrating security-group-to-security-group access control instead of CIDR-based trust.

## Repository Structure

```text
terraform-aws-network-foundation/
├── docs/
│   └── verification/          # Local verification evidence; PNGs are ignored by Git
├── examples/
│   ├── alternate-cidr/
│   │   ├── main.tf            # Verifies module reuse with a different VPC CIDR
│   │   └── providers.tf       # Terraform and AWS provider configuration
│   └── basic/
│       ├── main.tf            # Instantiates the reusable network module
│       └── providers.tf       # Terraform and AWS provider configuration
├── modules/
│   └── network/
│       ├── main.tf            # Network resources
│       ├── outputs.tf         # Module outputs
│       └── variables.tf       # Module inputs and validation
├── tests/
│   └── network.tftest.hcl     # Plan-mode Terraform tests
├── .gitignore
└── README.md
```

Terraform-generated `.terraform/` directories, state files, plan files, variable-value files, and verification screenshots containing AWS account information are intentionally excluded from version control.

## Requirements

Before using the project, install and configure:

- Terraform CLI `>= 1.10.0`
- AWS provider `~> 6.0`
- AWS CLI
- AWS credentials available through a supported AWS authentication method
- Permissions to create the AWS networking resources defined by the module

You can verify the AWS identity that the CLI and provider credentials resolve to with:

```bash
aws sts get-caller-identity
```

## Usage

The `examples/basic` directory is the deployment root. Its `main.tf` instantiates the reusable module:

```hcl
module "network" {
  source = "../../modules/network"

  # Pass required module inputs here.
  # Optional inputs only need to be passed when overriding their defaults.
}
```

Because the module currently provides defaults for its inputs, the basic example can use the defaults without explicitly passing values.

Initialize and review the example from its root directory:

```bash
cd examples/basic
terraform init
terraform validate
terraform plan
```

After reviewing the plan, deploy the infrastructure with:

```bash
terraform apply
```

Terraform will display the proposed changes and request confirmation before applying them.

## Module Inputs

| Input | Type | Default | Description |
| --- | --- | --- | --- |
| `aws_region` | `string` | `us-east-1` | AWS region associated with the module configuration |
| `availability_zones` | `list(string)` | `us-east-1a`, `us-east-1b` | Exactly two Availability Zones used for subnet deployment |
| `vpc_cidr` | `string` | `10.0.0.0/16` | IPv4 CIDR block used as the VPC address space |

The subnet resources derive four `/24` networks from `vpc_cidr` with `cidrsubnet()`. The module validates the expected two-AZ architecture and validates the VPC CIDR input before planning infrastructure.

## Module Outputs

| Output | Description |
| --- | --- |
| `vpc_id` | ID of the created VPC |
| `vpc_cidr` | CIDR block assigned to the VPC |
| `public_subnet_1a_id` | ID of the public subnet in `us-east-1a` |
| `public_subnet_1b_id` | ID of the public subnet in `us-east-1b` |
| `private_subnet_1a_id` | ID of the private subnet in `us-east-1a` |
| `private_subnet_1b_id` | ID of the private subnet in `us-east-1b` |
| `src_sg_id` | ID of the source security group |
| `target_sg_id` | ID of the target security group |
| `src_eni_id` | ID of the source ENI |
| `target_eni_id` | ID of the target ENI |

## Automated Testing

Terraform's native testing framework is used to provide automated guardrails. The test run uses `command = plan`, allowing the assertions to evaluate a plan without deploying additional test infrastructure.

The current test suite verifies that:

- Exactly four subnet resources are defined.
- Public subnets do not automatically assign public IPv4 addresses.
- Private subnets do not automatically assign public IPv4 addresses.

Run the test suite from the repository root:

```bash
terraform test
```

Expected result:

```text
Success! 1 passed, 0 failed.
```

## Quality Checks

Before considering changes complete, run the following checks:

```bash
terraform fmt -check -recursive
```

From `examples/basic`:

```bash
terraform validate
terraform plan
```

From the repository root:

```bash
terraform test
```

The final Week 1 review completed successfully with valid formatting/configuration, `1 passed, 0 failed` from the Terraform test suite, and a final plan reporting:

```text
No changes. Your infrastructure matches the configuration.
```

## Reachability Validation

AWS VPC Reachability Analyzer was used after deployment to validate the intended network behavior.

| Scenario | Expected Result | Verified Result |
| --- | --- | --- |
| Source ENI → Target ENI, TCP 443 | Reachable | Reachable |
| Source ENI → Target ENI, TCP 22 | Not reachable | Not reachable |
| Target/private ENI → Internet Gateway | Not reachable | Not reachable |

A failure-and-recovery check was also performed for the TCP 443 path. The path was initially unreachable when the required source security-group egress permission was absent; after the restrictive TCP 443 egress rule was added, Reachability Analyzer confirmed that connectivity was restored.

Verification screenshots are stored locally under `docs/verification/`. PNG files in that directory are ignored by Git because the raw AWS console evidence can contain account IDs and resource identifiers.

## Acceptance Criteria Verification

The final Week 1 review verified each project acceptance criterion against the Terraform configuration, deployed AWS resources, automated tests, and VPC Reachability Analyzer results.

| Acceptance Criterion | Verification | Result |
| --- | --- | --- |
| `terraform fmt`, `validate`, `test`, and `plan` pass | Formatting check completed successfully; configuration validated; `terraform test` returned `1 passed, 0 failed`; final plan completed successfully | Passed |
| Module deploys successfully in two Availability Zones | Successful deployment created the network across `us-east-1a` and `us-east-1b` | Passed |
| Public and private routing matches the design | Verified separate public/private route tables and explicit subnet associations; only the public route table provides a default route through the Internet Gateway | Passed |
| Three reachability scenarios return the expected results | TCP 443 was reachable; TCP 22 was not reachable; private target ENI to Internet Gateway was not reachable | Passed |
| A second environment can reuse the module with a different VPC CIDR | `examples/alternate-cidr` successfully planned using `10.10.0.0/16` without modifying the reusable network module | Passed |
| A second `terraform plan` reports no unintended changes | Final plan reported `No changes. Your infrastructure matches the configuration.` | Passed |
| README explains usage, architecture, inputs, outputs, security decisions, cost, validation, and teardown | Required project documentation is included in this README | Passed |
| Verification evidence is saved without exposing account IDs or sensitive state | Raw verification screenshots are retained locally under `docs/verification/` and excluded from Git; sanitized results are documented here | Passed |
| Friday deployment is ready for Saturday review and destruction | Final deployed infrastructure passed validation and was intentionally left intact for the walkthrough and teardown | Passed |

## Cost Controls

The project was deliberately scoped to avoid unnecessary AWS costs. It does **not** deploy:

- NAT Gateways
- Elastic IP addresses
- EC2 instances
- Load balancers
- Automatically assigned public IPv4 addresses

VPC Reachability Analyzer may incur charges per analysis, so analyses should only be run when needed for validation.

## Teardown

When the deployed environment is no longer needed, destroy it from the same example root that owns the Terraform state:

```bash
cd examples/basic
terraform plan -destroy
terraform destroy
```

Review the destroy plan carefully before confirming. After Terraform finishes, verify that the project resources have been removed from AWS.

## Project Goals Demonstrated

This project demonstrates practical experience with:

- Reusable Terraform module structure
- AWS VPC and subnet design across multiple Availability Zones
- Programmatic CIDR subnetting
- Explicit route-table associations
- Security-group referencing and least-privilege network rules
- Elastic Network Interfaces
- Terraform input validation and outputs
- Native Terraform plan-mode testing
- Infrastructure deployment and state-based drift detection
- AWS VPC Reachability Analyzer
- Cost-conscious infrastructure design
- Git hygiene for Terraform state and sensitive verification artifacts
