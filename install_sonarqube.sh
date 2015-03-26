
function run_mysql_command(){
	COMMAND="$1"
	
	USER=root
	HOST=localhost
	
	mysql --user="$USER" --password="$MYSQL_ROOT_PASSWORD" -h "$HOST" -e "$COMMAND"
}


function set_sonar_database(){
	# sonar/sonar
	run_mysql_command "CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;"
	run_mysql_command "CREATE USER 'sonar' IDENTIFIED BY 'sonar';"
	run_mysql_command "GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';"
	run_mysql_command "GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';"
	run_mysql_command "FLUSH PRIVILEGES;"
	
	echo "DATABASE UPDATED"
}

function download_sonar(){
	sudo apt-get install -y wget zip
	sudo wget http://dist.sonar.codehaus.org/sonarqube-4.5.1.zip
	unzip sonarqube-4.5.1.zip
	sudo mv sonarqube-4.5.1 /opt/sonar
	sudo chown -R www-data:www-data /opt/sonar
}

function configure_sonar(){
	sudo mv /opt/sonar/conf/sonar.properties /opt/sonar/conf/sonar.properties.old
	sudo cp $ROOT_FOLDER/etc/sonar/sonar.properties /opt/sonar/conf/sonar.properties 
}

function set_sonar_as_service(){
	sudo ln -s /opt/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
	sudo update-rc.d -f sonar remove
	sudo chmod 755 /etc/init.d/sonar
	sudo update-rc.d sonar defaults
	sudo /etc/init.d/sonar restart
}

function update_sonar_nginx(){
	if [ ! -f /etc/nginx/sites-enabled/sonar ]; then
		sudo rm /etc/nginx/sites-enabled/default
		sudo cp $ROOT_FOLDER/etc/nginx/sonar /etc/nginx/sites-available
		sudo ln -s /etc/nginx/sites-available/sonar /etc/nginx/sites-enabled/sonar
		sudo service nginx restart
	fi
}

function install_sonarqube(){
	download_sonar
	set_sonar_database
	configure_sonar
	set_sonar_as_service
	update_sonar_nginx
}