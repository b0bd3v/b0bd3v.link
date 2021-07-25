provider "aws" {
  region = "sa-east-1"
  profile = "roberto"
}

provider "aws" {
  alias = "global_region"
  region = "us-east-1"
  profile = "roberto"
}

variable "custom_domain" {
  description = "B0bd3v Site"
  type = string
  default = "b0bd3v.link"
}

variable "custom_domain_zone_name" {
  description = "The Route53 zone name of the b0bd3v site"
  type = string
  default = "b0bd3v.link."
}

data "aws_route53_zone" "custom_domain_zone" {
  name = var.custom_domain_zone_name
}

resource "aws_route53_record" "cloudfront_alias_domain" {
  zone_id = data.aws_route53_zone.custom_domain_zone.zone_id
  name = var.custom_domain
  type = "A"

  alias {
    name = aws_cloudfront_distribution.distribution.domain_name
    zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

module "tf_next" {
  source = "dealmore/next-js/aws"

  cloudfront_create_distribution = false
  cloudfront_external_id = aws_cloudfront_distribution.distribution.id
  cloudfront_external_arn = aws_cloudfront_distribution.distribution.arn

  deployment_name = "b0bd3v-link-application"
  providers = {
    aws.global_region = aws.global_region
  }

  tags = {
    "project" = "b0bd3v.link"
  }
}

module "cloudfront_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.custom_domain
  zone_id     = data.aws_route53_zone.custom_domain_zone.zone_id

  tags = {
    Name = "CloudFront ${var.custom_domain}"
  }

  # CloudFront works only with certs stored in us-east-1
  providers = {
    aws = aws.global_region
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled = true
  is_ipv6_enabled = true
  comment = "b0bd3v-link-application"
  aliases = [var.custom_domain]
  default_root_object = module.tf_next.cloudfront_default_root_object

  dynamic "default_cache_behavior" {
    for_each = module.tf_next.cloudfront_default_cache_behavior

    content {
      allowed_methods = default_cache_behavior.value["allowed_methods"]
      cached_methods = default_cache_behavior.value["cached_methods"]
      target_origin_id = default_cache_behavior.value["target_origin_id"]

      viewer_protocol_policy = default_cache_behavior.value["viewer_protocol_policy"]
      compress = default_cache_behavior.value["compress"]

      origin_request_policy_id = default_cache_behavior.value["origin_request_policy_id"]
      cache_policy_id = default_cache_behavior.value["cache_policy_id"]

      dynamic "lambda_function_association" {
        for_each = [default_cache_behavior.value["lambda_function_association"]]

        content {
          event_type = lambda_function_association.value["event_type"]
          lambda_arn = lambda_function_association.value["lambda_arn"]
          include_body = lambda_function_association.value["include_body"]
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = module.tf_next.cloudfront_ordered_cache_behaviors

    content {
      path_pattern = ordered_cache_behavior.value["path_pattern"]
      allowed_methods = ordered_cache_behavior.value["allowed_methods"]
      cached_methods = ordered_cache_behavior.value["cached_methods"]
      target_origin_id = ordered_cache_behavior.value["target_origin_id"]

      compress = ordered_cache_behavior.value["compress"]
      viewer_protocol_policy = ordered_cache_behavior.value["viewer_protocol_policy"]

      origin_request_policy_id = ordered_cache_behavior.value["origin_request_policy_id"]
      cache_policy_id = ordered_cache_behavior.value["cache_policy_id"]
    }
  }

  dynamic "origin" {
    for_each = module.tf_next.cloudfront_origins

    content {
      domain_name = origin.value["domain_name"]
      origin_id = origin.value["origin_id"]

      dynamic "origin_shield" {
        for_each = lookup(origin.value, "origin_shield", null) != null ? [true] : []

        content {
          enabled = lookup(origin.value["origin_shield"], "enabled", false)
          origin_shield_region = lookup(origin.value["origin_shield"], "origin_shield_region", null)
        }
      }

      dynamic "s3_origin_config" {
        for_each = lookup(origin.value, "s3_origin_config", null) != null ? [true] : []
        content {
          origin_access_identity = lookup(origin.value["s3_origin_config"], "origin_access_identity", null)
        }
      }

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin_config", null) != null ? [true] : []

        content {
          http_port = lookup(origin.value["custom_origin_config"], "http_port", null)
          https_port = lookup(origin.value["custom_origin_config"], "https_port", null)
          origin_protocol_policy = lookup(origin.value["custom_origin_config"], "origin_protocol_policy", null)
          origin_ssl_protocols = lookup(origin.value["custom_origin_config"], "origin_ssl_protocols", null)
          origin_keepalive_timeout = lookup(origin.value["custom_origin_config"], "origin_keepalive_timeout", null)
          origin_read_timeout = lookup(origin.value["custom_origin_config"], "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", null) != null ? origin.value["custom_header"] : []

        content {
          name = custom_header.value["name"]
          value = custom_header.value["value"]
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = module.tf_next.cloudfront_custom_error_response

    content {
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      error_code = custom_error_response.value["error_code"]
      response_code = custom_error_response.value["response_code"]
      response_page_path = custom_error_response.value["response_page_path"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = module.cloudfront_cert.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_domain_name" {
  value = module.tf_next.cloudfront_domain_name
}

output "custom_domain_name" {
  value = var.custom_domain
}
