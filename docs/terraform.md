## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.default_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.default_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.this_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_route53_record.default_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.sg_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.sg_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.sg_80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | (required) Access logs configuration. | <pre>object({<br/>    enabled              = bool<br/>    bucket_name          = string<br/>    logs_prefix          = optional(string, "")<br/>    logs_retention_years = optional(number, 3)<br/>    logs_archive_days    = optional(number, 30)<br/>  })</pre> | <pre>{<br/>  "bucket_name": "",<br/>  "enabled": false,<br/>  "logs_archive_days": 30,<br/>  "logs_prefix": "",<br/>  "logs_retention_years": 3<br/>}</pre> | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | n/a | `string` | `""` | no |
| <a name="input_cross_zone_load_balancing"></a> [cross\_zone\_load\_balancing](#input\_cross\_zone\_load\_balancing) | n/a | `bool` | `true` | no |
| <a name="input_default_ssl"></a> [default\_ssl](#input\_default\_ssl) | n/a | <pre>object({<br/>    enabled           = bool<br/>    cn                = string<br/>    san               = optional(list(string), [])<br/>    auto_validation   = optional(bool, false)<br/>    validation_method = optional(string, "DNS")<br/>    validation_domain = optional(string, "")<br/>    validation_email  = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "auto_validation": false,<br/>  "cn": "",<br/>  "enabled": false,<br/>  "san": [],<br/>  "validation_domain": "example.com",<br/>  "validation_email": "",<br/>  "validation_method": "DNS"<br/>}</pre> | no |
| <a name="input_delete_protection"></a> [delete\_protection](#input\_delete\_protection) | n/a | `bool` | `true` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | n/a | `string` | `"ipv4"` | no |
| <a name="input_is_internal"></a> [is\_internal](#input\_is\_internal) | Defaults to external ALB | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | n/a | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | n/a | `string` | `"001"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | n/a | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_acm_certificate_arn"></a> [default\_acm\_certificate\_arn](#output\_default\_acm\_certificate\_arn) | n/a |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | n/a |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | n/a |
| <a name="output_load_balancer_http_listener_arn"></a> [load\_balancer\_http\_listener\_arn](#output\_load\_balancer\_http\_listener\_arn) | n/a |
| <a name="output_load_balancer_https_listener_arn"></a> [load\_balancer\_https\_listener\_arn](#output\_load\_balancer\_https\_listener\_arn) | n/a |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | n/a |
| <a name="output_load_balancer_security_group_id"></a> [load\_balancer\_security\_group\_id](#output\_load\_balancer\_security\_group\_id) | n/a |
| <a name="output_load_balancer_security_group_name"></a> [load\_balancer\_security\_group\_name](#output\_load\_balancer\_security\_group\_name) | n/a |
| <a name="output_load_balancer_zone_id"></a> [load\_balancer\_zone\_id](#output\_load\_balancer\_zone\_id) | n/a |
