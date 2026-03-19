# AI Agents Guidelines

This document provides instructions for AI Agents working with the implementations of this Terraform module template.

## Template Guidelines
- **Avoid In place Modification** for implementations terraform-module-template is a template repository should not contain implementations.
- **Use Separate Repository for Implementations**: Implementations should be stored in separate repositories to maintain modularity and version control.
  - New repositories should be named in a way that reflects their purpose and functionality, prefixed with `terraform-module-` followed by the cloud provider (e.g., `terraform-module-aws`, `terraform-module-gcp`, `terraform-module-azurerm`).
  - Initialize new repostories for GitFlow: `make gitflow/init`
- **Supported Providers**:
 - AWS
 - GCP
 - Azure
 - MongoDB Atlas
 - Github


## Implementation Repository Guidelines

- **Avoid to modify**: Avoid at all costs, do not modify `locals-vars.tf`, `variables.tf`, and any files originating from the cloud provider boilerplate (e.g., `aws.tf`, `google.tf`, `azurerm.tf`, `variables-azurerm.tf`, `locals.tf`) in `.cloudopsworks/boilerplate/` (except `versions.tf`).
- **Use variables-module.tf**:
  - Rename the word `module` in `variables-module.tf` with a proper subname depending on the purpose of this module.
  - The subname must be no more than 12 chars (e.g., `variables-vpc.tf`).
- **Initialization**:
  - This template must be initialized on the target cloud provider using `Makefile`.
  - For AWS: `make init/aws`
  - For GCP: `make init/gcp`
  - For Azure: `make init/azurerm`
  - For MongoDB Atlas: `make init/mongodb`
  - For Github: `make init/github`
  - The initialization process for each cloud will copy its boilerplate files to the root module.
  - If a `versions.tf` file exists (e.g., from `.cloudopsworks/boilerplate/aws`, `gcp`, `azurerm`, or any other supported provider), the module is already initialized and under development.
  - You can check the current provider in `.cloudopsworks/.provider`.
  - You can modify `versions.tf` to include additional providers to help with the resolution of your task.
- **Avoid creating spurious configuration files**:
    - Do not create any configuration files that are not required for the task at hand.
    - Only create files that are necessary for the specific functionality being implemented.
    - Do not create provider files or provider initialization implementation at all.
- **Locals management**:
  - Do not create local variables that are not used in the module.
  - Keep local variable names descriptive and consistent with the module's purpose.
  - Use locals to encapsulate complex expressions and improve readability.
- **Documentation**:
  - Document all resources, variables, and outputs with clear and concise descriptions.
  - Use consistent formatting and structure for documentation.
  - Include examples and usage instructions where applicable.
- **Variables**:
  - Honor structured variables instead of lots of simple variables.
  - Prefer to have a single settings variable for simplicity and maintainability.
  - Use descriptive variable names that reflect their purpose.
  - Avoid using magic numbers and constants directly in code.
- **Mandatory Header**: Each .tf file must start with the following copyright header:
  ```hcl
  ##
  # (c) 2021-2025
  #     Cloud Ops Works LLC - https://cloudops.works/
  #     Find us on:
  #       GitHub: https://github.com/cloudopsworks
  #       WebSite: https://cloudops.works
  #     Distributed Under Apache v2.0 License
  #
  ```
- **Formatting, Validation & Linting**:
  - Formatting: `make fmt`
  - Validation & Linting: `make lint`
- **Repository Management**
  - Use process as described in the contributing guidelines: https://cloudopsworks.co/resources/gitflow-way-of-work/
- **Documentation Guideline**:
  - Documentation is maintained at README.yaml
  - Can use Markdown formatting for inner documentation on sections.
  - Act as an expert documentation professional, and terraform and terragrunt DevOps expert. Generated documentation should be human legible, use of tables for legibility is allowed.
  - Complete the documentation in @variables-module.tf (or whatever was renamed to, may find multiple variables-*.tf)  in order to represent the configuration to be applied on all resources,
    this documentation must be depicted in YAML format, and applied over each variable declaration section. Improve documentation putting after each item if its (Optional) or (Required)
    prefixed with a comment mark # and a description of it and possible default value, for example: id: "sampleid"   # (Required)
    The id of the item also for each item try to infer which are the possible values for them using the terraform module documentation as source, align to be more clear.
  - Once completed with inline documentation, proceed to modify README.yaml accordingly, in order to document properly following fields:
    name, description, introduction, usage, examples and quickstart, usage and examples must be depicted with terragrunt in mind avoid plain terraform hcl,
    also usage must document all variables used in the module with its corresponding structure documented inline also include the YAML formatted variables full documentation.
  - Updates: update using the criteria applied before, as new configurations were added to the module
  - Documentation generation must be done with command: `make readme`