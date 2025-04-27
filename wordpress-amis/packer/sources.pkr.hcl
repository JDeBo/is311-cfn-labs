source "amazon-ebs" "web" {
  ami_name      = "is311-web-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region

  vpc_filter {
    filters = {
      "tag:Name": var.vpc_name  # Replace with your VPC name
      "isDefault": "false"
    }
  }

  # Add subnet filter to find a subnet in the VPC
  subnet_filter {
    filters = {
      "tag:Name": "aws-controltower-PrivateSubnet1A"  # Replace with your VPC name
    }
  }

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  communicator = "ssh"
  ssh_interface = "session_manager"
  ssh_username = "ssm-user"
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"  # or your custom SSM instance profile
  
  temporary_iam_instance_profile_policy_document {
    Statement {
      Action = [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Effect = "Allow"
      Resource = ["*"]
    }
  }
      tags         = merge(local.ami_tags, { Component = "Web" })

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size          = 30
    volume_type          = "gp3"
    delete_on_termination = true
  }
}

source "amazon-ebs" "db" {
  ami_name      = "is311-db-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region
  
  vpc_filter {
    filters = {
      "tag:Name": var.vpc_name  # Replace with your VPC name
      "isDefault": "false"
    }
  }
  subnet_filter {
    filters = {
      "tag:Name": "aws-controltower-PrivateSubnet1A"  # Replace with your VPC name
    }
  }
  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  communicator = "ssh"
  ssh_interface = "session_manager"
  ssh_username = "ssm-user"
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"  # or your custom SSM instance profile
  
  temporary_iam_instance_profile_policy_document {
    Statement {
      Action = [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Effect = "Allow"
      Resource = ["*"]
    }
  }
      tags         = merge(local.ami_tags, { Component = "Database" })

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size          = 30
    volume_type          = "gp3"
    delete_on_termination = true
  }
}

source "vagrant" "web" {
  source_path = "fedora/${var.fedora_version}-cloud-base"
  provider    = "virtualbox"
  output_dir  = "output-web"
  communicator = "ssh"
  skip_add = true

  box_name    = "web"
}

source "vagrant" "db" {
  source_path = "fedora/${var.fedora_version}-cloud-base"
  provider    = "virtualbox"
  output_dir  = "output-db"
  communicator = "ssh"
  skip_add = true

  box_name    = "db"
}
