# AWS Infrastructure Labs

This repository contains a collection of hands-on labs designed to teach fundamental IT infrastructure concepts using AWS resources. These labs are suitable for beginners and focus on practical, real-world scenarios.

## Available Labs

1. **EFS Mounting Lab** (`efs-ec2/`)
   - Learn about network file systems
   - Practice mounting EFS to EC2 instances
   - Understand shared storage concepts

2. **Basic Server Monitoring Lab** (`monitoring-lab/`)
   - Learn essential Linux monitoring commands
   - Understand system resource usage
   - Practice reading and analyzing system logs
   - Experience monitoring under load conditions

3. **Basic Web Server Lab** (`webserver-lab/`)
   - Set up and configure a basic web server
   - Learn about web server logs and troubleshooting
   - Practice web content management
   - Understand web server security basics

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Basic understanding of Linux commands
- SSH key pair for EC2 instance access

## General Instructions

1. Each lab is contained in its own directory with:
   - A CloudFormation template (`lab.yaml`)
   - A detailed README with instructions
   - Any additional required files

2. To deploy a lab:
```bash
cd <lab-directory>
aws cloudformation create-stack --stack-name <lab-name> --template-body file://lab.yaml \
    --parameters ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR \
                ParameterKey=VpcId,ParameterValue=YOUR_VPC_ID \
                ParameterKey=SubnetId,ParameterValue=YOUR_SUBNET_ID
```

3. Follow the README in each lab directory for specific instructions

4. Always clean up resources after completing a lab:
```bash
aws cloudformation delete-stack --stack-name <lab-name>
```

## Lab Difficulty Levels

1. **EFS Mounting Lab**: Beginner
   - Basic Linux commands
   - File system operations
   - Network storage concepts

2. **Server Monitoring Lab**: Beginner
   - System monitoring basics
   - Resource usage analysis
   - Log interpretation

3. **Web Server Lab**: Beginner
   - Web server configuration
   - Basic HTML
   - Log analysis
   - Security concepts

## Contributing

Feel free to submit issues and enhancement requests!