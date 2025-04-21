# Basic Web Server Lab

This lab teaches you how to set up and manage a basic web server using Apache HTTP Server (httpd).

## Lab Objectives

1. Learn basic web server configuration
2. Understand web server logs and troubleshooting
3. Practice basic HTML file management
4. Learn about web server security concepts

## Lab Steps

1. Deploy the CloudFormation template:
```bash
aws cloudformation create-stack --stack-name webserver-lab --template-body file://lab.yaml \
    --parameters ParameterKey=KeyPairName,ParameterValue=YOUR_KEY_PAIR \
                ParameterKey=VpcId,ParameterValue=YOUR_VPC_ID \
                ParameterKey=SubnetId,ParameterValue=YOUR_SUBNET_ID
```

2. Connect to your instance:
```bash
ssh -i your-key.pem ec2-user@<instance-ip>
```

3. Verify web server status:
```bash
sudo systemctl status httpd
```

4. Explore web server configuration:
   - Main configuration file: `/etc/httpd/conf/httpd.conf`
   - Document root: `/var/www/html/`
   - Log files: 
     - Access log: `/var/www/html/access.log`
     - Error log: `/var/www/html/error.log`

5. Create and modify web content:
```bash
cd /var/www/html
sudo nano index.html
# Add some HTML content
```

6. Monitor web server activity:
```bash
# Watch access log in real-time
sudo tail -f /var/www/html/access.log

# Check error log
sudo tail -f /var/www/html/error.log
```

7. Test your website:
   - Open a web browser
   - Navigate to http://<instance-public-dns>
   - Try accessing non-existent pages to generate errors
   - Watch the logs as you generate traffic

## Success Criteria

- Web server is running and accessible
- You can modify web content
- You can read and understand server logs
- You understand basic web server security concepts

## Cleanup

Delete the CloudFormation stack:
```bash
aws cloudformation delete-stack --stack-name webserver-lab
```