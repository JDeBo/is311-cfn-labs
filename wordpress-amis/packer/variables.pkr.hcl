# variables.pkr.hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "wordpress_version" {
  type    = string
  default = "6.4.3"
}

variable "php_version" {
  type    = string
  default = "8.2"
}

variable "fedora_version" {
  type    = string
  default = "41"
}

variable "vpc_name" {
  type    = string
  default = "aws-controltower-VPC"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  
  ami_tags = {
    Environment = "Production"
    Builder     = "Packer"
    BuildDate   = local.timestamp
  }
}
