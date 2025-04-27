# WordPress Packer Configuration

This repository contains Hashicorp Packer configurations to build standardized images for a WordPress deployment. It creates two types of images:

- WordPress Web Server (Apache + PHP)
- WordPress Database Server (MariaDB)

Each image type can be built as either an AWS AMI or a Vagrant box.

## Prerequisites

- [Packer](https://www.packer.io/downloads) (>= 1.9.0)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials (for AWS AMIs)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (for Vagrant boxes)
- [Vagrant](https://www.vagrantup.com/downloads) (for Vagrant boxes)

## Configuration Files

- `required_plugins.pkr.hcl`: Defines required Packer plugins
- `variables.pkr.hcl`: Contains variable definitions for customizing builds
- `sources.pkr.hcl`: Defines the source images and builder configurations
- `web.pkr.hcl`: Configuration for building WordPress web server images
- `db.pkr.hcl`: Configuration for building WordPress database server images

## Quick Start

1. Clone this repository:

```bash
git clone <repository-url>
cd wordpress-packer
```

1. Initialize Packer plugins and validate config:

```bash
packer init .
packer validate .
```

1. Build the images

```bash
# Build all images
packer build .

# Build specific images
packer build -only="amazon-ebs.*" .    # AWS AMIs only
packer build -only="vagrant.*" .       # Vagrant boxes only
```

## Image Details

### WordPress Web Server

**Base Image:** Amazon Linux 2023 (AWS) / Fedora 38 (Vagrant)

**Installed Software:**

- Apache
- PHP 8.2 with WordPress extensions
- WordPress (latest version)

**Security Features:**

- Fail2ban
- SELinux enabled
- Firewall configuration
- Security-hardened Apache configuration

### WordPress Database Server

**Base Image:** Amazon Linux 2023 (AWS) / Fedora 38 (Vagrant)

**Installed Software:**

- MariaDB

**Features:**

- Preconfigured WordPress database and user
- Automated backup script
- Performance-tuned MariaDB configuration


## Default Credentials
>
> ⚠️ Warning : **These credentials are for development/testing only. This module is not intended for use in production**.

### Database Server SSH Access

Username: `wordpress`
Password: `is311-lab`

### Database Access

Database Name: `wordpress`
Database User: `wordpress_user`
Password: Generated during build (stored in /home/wordpress/db_info.txt)

## Customization

### Variables

You can customize the build by modifying variables.pkr.hcl or by passing variables at build time:

```bash
packer build \
  -var 'aws_region=us-west-2' \
  -var 'instance_type=t3.small' \
  .
```

### Available Variables

`aws_region`: AWS region (default: us-east-1)

`instance_type`: EC2 instance type (default: t3.micro)

`wordpress_version`: WordPress version (default: 6.4.3)

`php_version`: PHP version (default: 8.2)

### Security Considerations

The default configuration includes password-based SSH access for the WordPress user. This is intended for development/testing only.

Troubleshooting

1. If Packer initialization fails:

```bash
rm -rf ~/.packer.d/plugins
packer init .
```

1. If AWS builds fail, verify:
    - AWS credentials are configured
    - IAM permissions are sufficient
    - VPC/subnet configuration is correct
1. If Vagrant builds fail:
    - Ensure VirtualBox is installed and running
    - Verify Vagrant is properly installed
    - Check for sufficient disk space

## Contributing

1. Fork the repository
1. Create a feature branch
1. Commit your changes
1. Push to the branch
1. Create a Pull Request

## License

MIT License
