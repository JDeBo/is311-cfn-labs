# Basic Server Monitoring Lab

This lab teaches you fundamental Linux server monitoring concepts and tools.

## Lab Objectives

1. Learn basic Linux monitoring commands
2. Understand system resource usage (CPU, memory, disk)
3. Practice reading and interpreting system logs
4. Experience monitoring a server under load

## Lab Steps

1. Deploy the CloudFormation template:
```bash
aws cloudformation create-stack --stack-name monitoring-lab --template-body file://lab.yaml \
    --parameters ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR \
                ParameterKey=VpcId,ParameterValue=YOUR_VPC_ID \
                ParameterKey=SubnetId,ParameterValue=YOUR_SUBNET_ID
```

2. Connect to your instance:
```bash
ssh -i your-key.pem ec2-user@<instance-ip>
```

3. Explore basic monitoring commands:
   - Check system uptime: `uptime`
   - View CPU usage: `top` or `htop`
   - Monitor disk I/O: `iotop`
   - Check memory usage: `free -h`
   - View system statistics: `vmstat 1`

4. Analyze system logs:
   - View CPU statistics log: `cat /home/ec2-user/cpu_stats.log`
   - Check system messages: `sudo tail -f /var/log/messages`

5. Monitor system under load:
   - The instance is running a stress test in the background
   - Observe CPU usage changes using different tools
   - Compare normal vs stressed states

6. Practice with SAR (System Activity Reporter):
```bash
# Install if not present
sudo yum install -y sysstat

# Collect data for 5 minutes
sar 60 5

# View CPU statistics
sar -u

# View memory statistics
sar -r
```

## Success Criteria

- You can use basic monitoring tools (top, htop, iotop)
- You can interpret system resource usage
- You understand how to read and analyze system logs
- You can identify when a system is under stress

## Cleanup

Delete the CloudFormation stack:
```bash
aws cloudformation delete-stack --stack-name monitoring-lab
```