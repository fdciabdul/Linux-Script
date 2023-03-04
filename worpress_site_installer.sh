 #!/bin/bash
clear
echo "Please enter Project Name"
read project_name
mkdir /var/www/html/${project_name}
# cd /var/www/html/${project_name}
echo "Please enter repo url"
read repo_url
git clone ${repo_url} /var/www/html/${project_name}
cp -r wordpress/* /var/www/html/${project_name}/
# Optional
echo "Please enter local url"
read local_url
echo "Please enter local ip"
read local_ip

echo "Please enter following commands to create Virtual host of the application."
echo ">>"
echo "sudo cat <<EOF > /etc/apache2/sites-enabled/${local_url}.conf \
<VirtualHost ${local_ip}:80> \
 ServerName ${local_url} \
 DocumentRoot \"/var/www/html/${project_name}\" \
 <Directory \"/var/www/html/${project_name}\"> \
   AllowOverride All \
   Require all granted \
 </Directory> \
</VirtualHost> \
EOF"
echo ">>"
echo "sudo echo '${local_ip}   ${local_url}' >> /etc/hosts"
echo ">>"
echo "sudo service apache2 restart"
