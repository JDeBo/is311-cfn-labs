build {
  name = "web"
  
  sources = [
    "source.amazon-ebs.web",
    "source.vagrant.web"
  ]

  # Update system and install dependencies
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y httpd wget tar",
      "sudo dnf install -y php php-mysqlnd php-fpm php-json php-gd",
      "sudo dnf install -y php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip"
    ]
  }

  # Configure Apache
  provisioner "shell" {
    inline = [
      "sudo systemctl enable httpd",
      "sudo systemctl enable php-fpm",
      "sudo setsebool -P httpd_can_network_connect=1",
      "sudo chown -R apache:apache /var/www/html/"
    ]
  }

  # Download and configure WordPress
  provisioner "shell" {
    inline = [
      "cd /tmp",
      "wget https://wordpress.org/wordpress-${var.wordpress_version}.tar.gz",
      "tar -xzf wordpress-${var.wordpress_version}.tar.gz",
      "sudo cp -r wordpress/* /var/www/html/",
      "sudo chown -R apache:apache /var/www/html/",
      "sudo chmod -R 755 /var/www/html/"
    ]
  }

  # Configure PHP
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini",
      "sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php.ini",
      "sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php.ini",
      "sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php.ini"
    ]
  }

  # Security hardening
  provisioner "shell" {
    inline = [
      "sudo dnf install -y fail2ban",
      "sudo systemctl enable fail2ban",
      "sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local",
      "sudo sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/httpd/conf/httpd.conf",
      "sudo sed -i 's/ServerSignature On/ServerSignature Off/' /etc/httpd/conf/httpd.conf"
    ]
  }
}
