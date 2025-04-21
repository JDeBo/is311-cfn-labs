# VPC Peering Lab

This lab teaches you about VPC networking concepts by creating two VPCs and establishing a peering connection between them.

## Architecture

The lab creates:
- Two VPCs with different CIDR ranges
- One subnet in each VPC
- Internet Gateways for each VPC
- EC2 instances in each VPC
- A VPC peering connection
- Required route table entries
- Security groups allowing SSH and ICMP (ping)

## Lab Steps

1. **Deploy the CloudFormation Stack**
```bash
aws cloudformation create-stack \
  --stack-name vpc-peering-lab \
  --template-body file://lab.yaml \
  --parameters ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR
```

2. **Wait for Stack Creation**
- Wait until the stack status is CREATE_COMPLETE
- Note the output values for the instance IPs

3. **Connect to Instance-A**
```bash
ssh -i your-key.pem ec2-user@<instance-a-public-ip>
```

4. **Test Connectivity to Instance-B**
```bash
# Ping Instance-B using its private IP
ping <instance-b-private-ip>

# The ping should work because of the VPC peering connection
```

5. **Connect to Instance-B**
```bash
ssh -i your-key.pem ec2-user@<instance-b-public-ip>
```

6. **Examine Network Configuration**
```bash
# Check routing table
ip route show

# Try ping back to Instance-A
ping <instance-a-private-ip>
```

## Learning Objectives

After completing this lab, you should understand:
- VPC CIDR ranges and IP addressing
- VPC peering concepts
- Route table configuration
- Security group rules for cross-VPC communication
- Basic network troubleshooting

## Troubleshooting Tips

If ping doesn't work:
1. Check security group rules
2. Verify route table entries
3. Confirm VPC peering connection is active
4. Ensure CIDR ranges don't overlap

## Clean Up

Delete the CloudFormation stack to remove all resources:
```bash
aws cloudformation delete-stack --stack-name vpc-peering-lab
```