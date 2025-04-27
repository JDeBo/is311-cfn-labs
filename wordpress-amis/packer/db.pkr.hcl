build {
  name = "db"
  
  sources = [
    "source.amazon-ebs.db",
    "source.vagrant.db"
  ]

  # Update system and install MariaDB
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y mariadb mariadb-server",
      "sudo systemctl enable mariadb"
    ]
  }

  # Create WordPress system user with SSH access
  provisioner "shell" {
    inline = [
      # Create wordpress user
      "sudo useradd -m -s /bin/bash wordpress",
      # Set password for wordpress user (for lab purposes only)
      "echo 'wordpress:is311-lab' | sudo chpasswd",
      # Allow password authentication for SSH
      "sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      # Create specific Match block for wordpress user
      "echo 'Match User wordpress' | sudo tee -a /etc/ssh/sshd_config",
      "echo '    PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config",
      # Restart SSH service to apply changes
      "sudo systemctl restart sshd"
    ]
  }

  # Configure MariaDB
  provisioner "shell" {
    inline = [
      "sudo systemctl start mariadb",
      "sudo mysql_secure_installation --set-root-pass='${uuidv4()}'", # Generate random initial password
      "sudo sed -i '/\\[mysqld\\]/a character-set-server = utf8mb4\\ncollation-server = utf8mb4_unicode_ci' /etc/my.cnf.d/mariadb-server.cnf",
      "sudo sed -i '/\\[mysqld\\]/a max_allowed_packet = 64M' /etc/my.cnf.d/mariadb-server.cnf",
      "sudo sed -i '/\\[mysqld\\]/a innodb_buffer_pool_size = 256M' /etc/my.cnf.d/mariadb-server.cnf",
      "sudo systemctl restart mariadb"
    ]
  }

  # Create WordPress Database and User
  provisioner "shell" {
    environment_vars = [
      "DB_NAME=wordpress",
      "DB_USER=wordpress_user",
      "DB_PASSWORD=${uuidv4()}", # Generate random password
      "DB_HOST=%"  # Allow connections from any host
    ]
    inline = [
      "sudo mysql -e \"CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\"",
      "sudo mysql -e \"CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';\"",
      "sudo mysql -e \"GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';\"",
      "sudo mysql -e \"FLUSH PRIVILEGES;\"",
      # Save database credentials to wordpress user's home directory
      "echo \"Database Name: $DB_NAME\" | sudo tee /home/wordpress/db_info.txt > /dev/null",
      "echo \"Database User: $DB_USER\" | sudo tee -a /home/wordpress/db_info.txt > /dev/null",
      "echo \"Database Password: $DB_PASSWORD\" | sudo tee -a /home/wordpress/db_info.txt > /dev/null",
      "sudo chown wordpress:wordpress /home/wordpress/db_info.txt",
      "sudo chmod 600 /home/wordpress/db_info.txt"
    ]
  }

  # Configure MariaDB for remote access
  provisioner "shell" {
    inline = [
      "sudo sed -i '/\\[mysqld\\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf",
      "sudo systemctl restart mariadb"
    ]
  }

  # Security hardening
  provisioner "shell" {
    inline = [
      "sudo dnf install -y fail2ban",
      "sudo systemctl enable fail2ban",
      "sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local",
      # Configure firewall
      "sudo dnf install -y firewalld",
      "sudo systemctl enable firewalld",
      "sudo systemctl start firewalld",
      "sudo firewall-cmd --permanent --add-service=mysql",
      "sudo firewall-cmd --permanent --add-service=ssh",
      "sudo firewall-cmd --reload",
      # Additional database security
      "sudo mysql -e \"DELETE FROM mysql.user WHERE User='';\"",
      "sudo mysql -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\"",
      "sudo mysql -e \"DROP DATABASE IF EXISTS test;\"",
      "sudo mysql -e \"DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';\"",
      "sudo mysql -e \"FLUSH PRIVILEGES;\""
    ]
  }

  # Create backup script
  provisioner "shell" {
    inline = [
      "sudo tee /usr/local/bin/backup-db.sh > /dev/null << 'EOL'",
      "#!/bin/bash",
      "BACKUP_DIR=/var/backup/mysql",
      "DATETIME=$(date +%Y%m%d_%H%M%S)",
      "mkdir -p $BACKUP_DIR",
      "mysqldump wordpress | gzip > $BACKUP_DIR/wordpress_$DATETIME.sql.gz",
      "find $BACKUP_DIR -type f -mtime +7 -delete",
      "EOL",
      "sudo chmod +x /usr/local/bin/backup-db.sh",
      # Set up daily cron job for backups
      "echo '0 2 * * * root /usr/local/bin/backup-db.sh' | sudo tee /etc/cron.d/wordpress-backup > /dev/null",
      "sudo chmod 644 /etc/cron.d/wordpress-backup"
    ]
  }

  # Performance tuning
  provisioner "shell" {
    inline = [
      "sudo tee -a /etc/my.cnf.d/mariadb-server.cnf > /dev/null << 'EOL'",
      "[mysqld]",
      "innodb_buffer_pool_size = 256M",
      "innodb_log_file_size = 64M",
      "innodb_flush_method = O_DIRECT",
      "innodb_flush_log_at_trx_commit = 2",
      "max_connections = 150",
      "query_cache_size = 32M",
      "query_cache_type = 1",
      "slow_query_log = 1",
      "slow_query_log_file = /var/log/mysql/slow-query.log",
      "long_query_time = 2",
      "EOL",
      "sudo mkdir -p /var/log/mysql",
      "sudo chown mysql:mysql /var/log/mysql",
      "sudo systemctl restart mariadb"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf/*",
      "sudo rm -rf /tmp/*"
    ]
  }

  # Create manifest with database information
  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
    custom_data = {
      database_name = "wordpress"
      database_user = "wordpress_user"
      database_host = "localhost"
      backup_script = "/usr/local/bin/backup-db.sh"
    }
  }
}
