#!/bin/bash
amazon-linux-extras enable php7.4
yum install -y httpd php-cli php-pdo php-fpm php-json php-mysqlnd
echo Listen 8080 > /etc/httpd/conf.d/ports.conf
systemctl enable --now httpd php-fpm
cat <<EOF > /var/www/html/index.php
<?php
\$servername = "${dbhost}";
\$serverport = "${dbport}";
\$username = "${dbuser}";
\$password = "${dbpass}";
\$database = "${dbname}";

echo gethostname()."<br/>\n";
// Create connection
\$conn = new mysqli(\$servername, \$username, \$password, \$database, \$serverport);

// Check connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully!<br/>\n";
?>
EOF
