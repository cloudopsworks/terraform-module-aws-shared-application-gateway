mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/alb-test/1234567890abcdef"
    }
  }
}

variables {
  org = {
    organization_name = "example"
    organization_unit = "platform"
    environment_type  = "test"
    environment_name  = "test"
  }
  vpc_id              = "vpc-01234567890123456"
  public_subnet_ids   = ["subnet-01234567890123456", "subnet-01234567890123457"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
}

run "security_defaults" {
  command = plan

  variables {
    extra_listeners = [
      { port = 8080 },
      { port = 8081, ssl = false },
      { port = 8443, ssl = true },
    ]
  }

  assert {
    condition     = aws_lb.this.drop_invalid_header_fields
    error_message = "The ALB should drop invalid HTTP headers by default."
  }

  assert {
    condition = alltrue([
      for listener in [
        aws_lb_listener.this_http,
        aws_lb_listener.extra_https["port-8080"],
        aws_lb_listener.extra_https["port-8081"],
        ] : try(
        listener.protocol == "HTTP" &&
        one(listener.default_action).type == "redirect" &&
        one(one(listener.default_action).redirect).protocol == "HTTPS" &&
        one(one(listener.default_action).redirect).port == "443" &&
        one(one(listener.default_action).redirect).status_code == "HTTP_301",
        false
      )
    ])
    error_message = "The main and extra HTTP listeners should redirect to HTTPS on port 443 by default."
  }

  assert {
    condition = alltrue([
      for listener in [
        aws_lb_listener.this_https,
        aws_lb_listener.extra_https["port-8443"],
        ] : (
        listener.protocol == "HTTPS" &&
        listener.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09" &&
        one(listener.default_action).type == "fixed-response" &&
        one(one(listener.default_action).fixed_response).status_code == "401"
      )
    ])
    error_message = "Both HTTPS listeners should use the ELB.17 policy and return HTTP 401 by default."
  }
}

run "explicit_overrides" {
  command = plan

  variables {
    drop_invalid_header_fields = false
    ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"
    default_action = {
      type  = "fixed-response"
      fixed = { status = "403" }
    }
    extra_listeners = [
      { port = 8080 },
      {
        port = 8081
        default_action = {
          type = "redirect"
          redirect = {
            protocol    = "HTTPS"
            port        = "8443"
            status_code = "HTTP_302"
          }
        }
      },
      {
        port = 8082
        type = "forward"
        forward = {
          target_groups = [{
            arn    = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/legacy/1234567890abcdef"
            weight = 100
          }]
        }
      },
      { port = 8443, ssl = true },
      {
        port = 9443
        ssl  = true
        default_action = {
          type  = "fixed-response"
          fixed = { status = "404" }
        }
      },
    ]
  }

  assert {
    condition     = !aws_lb.this.drop_invalid_header_fields
    error_message = "An explicit setting should disable invalid HTTP header dropping."
  }

  assert {
    condition = alltrue([
      for listener in [
        aws_lb_listener.this_https,
        aws_lb_listener.extra_https["port-8443"],
        aws_lb_listener.extra_https["port-9443"],
      ] : listener.ssl_policy == "ELBSecurityPolicy-TLS-1-2-2017-01"
    ])
    error_message = "The explicit SSL policy should apply to every HTTPS listener."
  }

  assert {
    condition = (
      one(one(aws_lb_listener.this_https.default_action).fixed_response).status_code == "403" &&
      one(one(aws_lb_listener.extra_https["port-8443"].default_action).fixed_response).status_code == "403" &&
      one(one(aws_lb_listener.extra_https["port-9443"].default_action).fixed_response).status_code == "404"
    )
    error_message = "The module action should apply to HTTPS listeners unless an extra listener sets its own action."
  }

  assert {
    condition = (
      try(one(one(aws_lb_listener.extra_https["port-8080"].default_action).redirect).port, null) == "443" &&
      try(one(one(aws_lb_listener.extra_https["port-8081"].default_action).redirect).port, null) == "8443" &&
      try(one(one(aws_lb_listener.extra_https["port-8081"].default_action).redirect).status_code, null) == "HTTP_302"
    )
    error_message = "Extra HTTP listeners should default to HTTPS on port 443 and honor an explicit per-listener redirect."
  }

  assert {
    condition = (
      one(aws_lb_listener.extra_https["port-8082"].default_action).type == "forward" &&
      one(one(one(aws_lb_listener.extra_https["port-8082"].default_action).forward).target_group).arn == "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/legacy/1234567890abcdef"
    )
    error_message = "An existing top-level forward action should still forward to its configured target group."
  }
}
