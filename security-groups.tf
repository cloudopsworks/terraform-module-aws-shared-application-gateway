##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

# Security groups for ALB
resource "aws_security_group" "this" {
  name        = "alb-sg-${local.system_name}"
  description = "Shared/Central Load Balancer security group for ${local.system_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.all_tags,
    {
      Name = "alb-sg-${local.system_name}"
    }
  )

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "sg_all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic by default"
  tags              = local.all_tags
}

resource "aws_vpc_security_group_ingress_rule" "sg_80" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound traffic on port 80"
  tags              = local.all_tags
}

resource "aws_vpc_security_group_ingress_rule" "sg_443" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound traffic on port 443"
  tags              = local.all_tags
}
