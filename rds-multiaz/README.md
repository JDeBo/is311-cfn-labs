# RDS Multi-AZ Lab

This lab teaches you about high availability using Amazon RDS Multi-AZ deployments and database connectivity.

## Architecture

The lab creates:
- A VPC with public and private subnets across two AZs
- A Multi-AZ RDS MySQL instance
- An EC2 instance to serve as database client
- Required security groups and network configuration

## Lab Steps

1. **Deploy the CloudFormation Stack**
```bash
aws cloudformation create-stack \
  --stack-name rds-multiaz-lab \
  --template-body file://lab.yaml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR \
    ParameterKey=DBPassword,ParameterValue=YOUR_DB_PASSWORD \
  --capabilities CAPABILITY_IAM
```

2. **Connect to the EC2 Instance**
```bash
ssh -i your-key.pem ec2-user@<ec2-public-ip>
```

3. **Test Database Connection**
```bash
# Connect to the database
mysql -h <rds-endpoint> -P 3306 -u admin -p

# Create test database and table
CREATE DATABASE testdb;
USE testdb;
CREATE TABLE users (id INT, name VARCHAR(50));
INSERT INTO users VALUES (1, 'test user');
```

4. **Simulate a Failure**
- Go to the RDS console
- Select your database instance
- Click "Reboot" and choose "Reboot with failover"
- Observe the failover process
- Try to connect to the database again - it should still work!

5. **Monitor the Failover**
```bash
# Check the connection during failover
watch -n 1 "mysql -h <rds-endpoint> -u admin -p<password> -e 'SELECT NOW()'"
```

## Learning Objectives

After completing this lab, you should understand:
- RDS Multi-AZ deployment architecture
- How failover works in Multi-AZ deployments
- Database connectivity best practices
- VPC networking for database access
- Security group configuration for databases

## Troubleshooting Tips

If you can't connect to the database:
1. Check security group rules
2. Verify the endpoint address
3. Confirm the EC2 instance is in the correct subnet
4. Test network connectivity using telnet

## Clean Up

Delete the CloudFormation stack to remove all resources:
```bash
aws cloudformation delete-stack --stack-name rds-multiaz-lab
```

Note: RDS deletion protection is not enabled in this lab for easy cleanup. In production, you should enable deletion protection.