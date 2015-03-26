
#Jenkins Debian installation
#Jenkins will be running on port :81

function update_jenkins_nginx(){
	if [ ! -f /etc/nginx/sites-enabled/jenkins ]; then
		sudo rm /etc/nginx/sites-enabled/default
		sudo cp $ROOT_FOLDER/etc/nginx/jenkins /etc/nginx/sites-available
		sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins
		sudo service nginx restart
	fi
}

function install_jenkins(){
	wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get -y install jenkins nginx
	update_jenkins_nginx
	sudo service jenkins start
}
