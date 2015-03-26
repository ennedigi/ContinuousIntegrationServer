
######
## PHABRICATOR
##
# This script is tested on Ubuntu 14.04 where Apache2 is included and run by default
# And php5-fpm runs by default over unix socket

#Run install_phabricator to install it on the server

remove_apache2(){
	sudo apt-get remove -y apache2
}

install_packages(){
	
	sudo apt-get update

	#SET MYSQLPASSWORD
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

	sudo apt-get -y install \
	  vim rcconf build-essential curl git wget \
	  nginx \
	  mysql-server dpkg-dev \
	  php5 php5-mysql php5-gd php5-dev php5-curl php-apc php5-cli php5-json
	  
	  sudo apt-get -y install php5-fpm
	  
	#Compile pcntl
	  
	apt-get source php5
	PHP5=`ls -1F | grep '^php5-.*/$'`
	(cd $PHP5/ext/pcntl && phpize && ./configure && make && sudo make install)
	 


}

download_phabricator(){
	
	cd /opt
	#Install phabricator
	sudo git clone https://github.com/phacility/libphutil.git
	sudo git clone https://github.com/phacility/arcanist.git
	sudo git clone https://github.com/phacility/phabricator.git
	
	sudo chown -R www-data:www-data phabricator

}

update_phabricator_database(){
	#Update the database
	sudo /opt/phabricator/bin/config set mysql.host localhost
	sudo /opt/phabricator/bin/config set mysql.port 3306
	sudo /opt/phabricator/bin/config set mysql.user root
	sudo /opt/phabricator/bin/config set mysql.pass $MYSQL_ROOT_PASSWORD
	
	sudo /opt/phabricator/bin/storage upgrade --force
}

update_phabricator_nginx(){

	#Copy nginx settings file
	if [ ! -f /etc/nginx/sites-enabled/phabricator ]; then
		sudo rm /etc/nginx/sites-enabled/default
		sudo cp $ROOT_FOLDER/etc/nginx/phabricator /etc/nginx/sites-available
		sudo ln -s /etc/nginx/sites-available/phabricator /etc/nginx/sites-enabled/phabricator
		sudo service nginx restart
		sudo service php5-fpm restart
	fi

}

configure_phpfpm_on_other_ubuntu(){
	sudo sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf
	sudo service php5-fpm restart
}

function install_phabricator(){
	#Phabricator will be running on :80 port
	
	install_packages
	download_phabricator
	update_phabricator_database
	remove_apache2
	update_phabricator_nginx
}