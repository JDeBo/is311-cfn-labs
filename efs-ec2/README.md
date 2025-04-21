# EFS Mounting Lab

This lab teaches you how to work with Amazon Elastic File System (EFS) and mount it to EC2 instances.

## Lab Objectives

1. Understand the concept of network file systems
2. Learn how to mount an EFS filesystem to an EC2 instance
3. Practice basic file operations across mounted filesystems
4. Understand security group configurations for EFS

## Lab Steps

1. Deploy the CloudFormation template:
```bash
aws cloudformation create-stack --stack-name efs-lab --template-body file://lab.yaml \
    --parameters ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR \
                ParameterKey=VpcId,ParameterValue=YOUR_VPC_ID \
                ParameterKey=SubnetId,ParameterValue=YOUR_SUBNET_ID
```

2. Once deployed, you'll have:
   - Two EC2 instances (source and destination)
   - An EFS filesystem
   - Required security groups

3. Connect to the source instance:
```bash
ssh -i your-key.pem ec2-user@<source-instance-ip>
```

4. Verify the EFS mount on the destination instance:
```bash
ssh ec2-user@<dest-instance-ip>
# Password is: is311rocks
cd /mnt/efs
ls -la
```

5. Practice file operations:
   - Create files on the source instance
   - Verify they appear on the destination instance
   - Test file permissions and ownership

## Success Criteria

- You can successfully mount the EFS filesystem
- You can create and view files from both instances
- You understand the security group configurations needed for EFS

## Cleanup

Delete the CloudFormation stack:
```bash
aws cloudformation delete-stack --stack-name efs-lab
```