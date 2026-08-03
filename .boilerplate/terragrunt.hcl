locals {
  local_vars  = yamldecode(file("./inputs.yaml"))
  spoke_vars  = yamldecode(file(find_in_parent_folders("spoke-inputs.yaml")))
  region_vars = yamldecode(file(find_in_parent_folders("region-inputs.yaml")))
  env_vars    = yamldecode(file(find_in_parent_folders("env-inputs.yaml")))
  global_vars = yamldecode(file(find_in_parent_folders("global-inputs.yaml")))

  local_tags  = jsondecode(file("./local-tags.json"))
  spoke_tags  = jsondecode(file(find_in_parent_folders("spoke-tags.json")))
  region_tags = jsondecode(file(find_in_parent_folders("region-tags.json")))
  env_tags    = jsondecode(file(find_in_parent_folders("env-tags.json")))
  global_tags = jsondecode(file(find_in_parent_folders("global-tags.json")))

  tags = merge(
    local.global_tags,
    local.env_tags,
    local.region_tags,
    local.spoke_tags,
    local.local_tags
  )
}

include "root" {
  path = find_in_parent_folders("{{ .RootFileName }}")
}
{{ if .vpc_dependency_enabled }}
dependency "vpc" {
  config_path = "{{ .vpc_dependency_path }}"
  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "destroy"]
  mock_outputs = {
    intra_subnets = [
      "subnet-01234567890123456",
      "subnet-01234567890123457",
      "subnet-01234567890123458",
    ]
    private_subnets = [
      "subnet-01234567890123456",
      "subnet-01234567890123457",
      "subnet-01234567890123458",
    ]
    public_subnets = [
      "subnet-01234567890123456",
      "subnet-01234567890123457",
    ]
    vpc_id         = "vpc-12345678901234"
    vpc_cidr_block = "1.0.0.0/8"
  }
}
{{ end }}
{{- if .acm_dependency_enabled }}
dependency "acm" {
  config_path                             = "{{ .acm_dependency_path }}"
  mock_outputs_allowed_terraform_commands = ["validate", "destroy"]
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}
{{ end }}
{{- if .webacl_dependency_enabled }}
dependency "waf" {
  config_path = "{{ .webacl_dependency_path }}"
  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "destroy"]
  mock_outputs = {
    web_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/sample-web-acl/12345678-1234-1234-1234-123456789012"
  }
}
{{ end }}
terraform {
  source = "{{ .sourceUrl }}"
}

inputs = {
  is_hub    = {{ .is_hub }}
  org       = local.env_vars.org
  spoke_def = local.spoke_vars.spoke
  {{- range .requiredVariables }}
  {{- if ne .Name "org" }}
  {{- if and $.vpc_dependency_enabled (eq .Name "vpc_id") }}
  {{ .Name }} = dependency.vpc.outputs.vpc_id
  {{- else }}
  {{ .Name }} = local.local_vars.{{ .Name }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- range .optionalVariables }}
  {{- if not (eq .Name "extra_tags" "is_hub" "spoke_def" "org") }}
  {{- if and $.vpc_dependency_enabled (eq .Name "vpc_id") }}
  {{ .Name }} = dependency.vpc.outputs.vpc_id
  {{- else if and (and $.vpc_dependency_enabled (eq .Name "private_subnet_ids")) (eq $.vpc_subnet_type "intra" "private") }}
  {{ .Name }} = dependency.vpc.outputs.{{ $.vpc_subnet_type }}_subnets
  {{- else if and (and $.vpc_dependency_enabled (eq .Name "public_subnet_ids")) (eq $.vpc_subnet_type "public") }}
  {{ .Name }} = dependency.vpc.outputs.public_subnets
  {{- else if and $.webacl_dependency_enabled (eq .Name "web_acl_arn") }}
  {{ .Name }} = dependency.waf.outputs.web_acl_arn
  {{- else if and $.acm_dependency_enabled (eq .Name "acm_certificate_arn") }}
  {{ .Name }} = dependency.acm.outputs.acm_certificate_arn
  {{- else }}
  {{ .Name }} = try(local.local_vars.{{ .Name }}, {{ .DefaultValue }})
  {{- end }}
  {{- end }}
  {{- end }}
  extra_tags = local.tags
}
