terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Adjust this to your preferred region
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  bucket_name = "is311-lab-templates-${local.account_id}-${data.aws_region.current.name}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = local.bucket_name
  
  # Enable versioning for safety
  versioning = {
    enabled = true
  }

  # Allow public read access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Bucket policy for public read access
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = ["arn:aws:s3:::${local.bucket_name}/*"]
      }
    ]
  })
}

# Upload CloudFormation templates to the bucket
resource "aws_s3_object" "efs_ec2_template" {
    for_each = toset([ "monitoring","webserver","efs-ec2" ])
  bucket = module.s3_bucket.s3_bucket_id
  key    = "${each.key}/lab.yaml"
  source = "${path.module}/../${each.key}/lab.yaml"  # Adjust path based on your repo structure
  etag   = filemd5("${path.module}/../${each.key}/lab.yaml")
  content_type = "text/yaml"
}

# Output the bucket name
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_bucket.s3_bucket_id
}
