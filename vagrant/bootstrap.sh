#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo add-apt-repository ppa:upubuntu-com/xampp

sudo apt-get update

sudo apt-get clean

sudo apt-get -y install libtool
sudo apt-get -y install git
sudo apt-get -y install python-dev libyaml-dev libffi-dev
sudo apt-get -y install python-pip
sudo apt-get -y install mysql-server mysql-client libmysqlclient-dev

#Python 3 stuff
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:fkrull/deadsnakes
sudo apt-get -y update
sudo apt-get -y install python3.4

#virtualenv stuff
sudo apt-get -y install python-virtualenv
sudo virtualenv -p /usr/bin/python3.4 /opt/allianceVenv

#Postgresql stuff
sudo apt-get -y postgresql-9.1 libpq5 libpq-dev postgresql-client-9.1 postgresql-common ssl-cert postgresql-contrib-9.1 postgresql-server-dev-9.1
sudo apt-get -y install -f
cat << EOF | su - postgres -c psql
-- Create database user:
CREATE USER vagrant WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE alliance% to vagrant;
EOF
createdb alliance_auth
createdb alliance_forum
createdb alliance_jabber
createdb alliance_mumble
createdb alliance_killboard

cd /vagrant/

sudo pip install --upgrade pip

# Pip moved location after upgrade from 1.0
sudo ln -s /usr/local/bin/pip /usr/bin/pip 2>/dev/null

sudo pip install --allow-external mysql-connector-python mysql-connector-python
sudo pip install --allow-external python-openfire python-openfire==0.2.3-beta
sudo pip install https://github.com/eve-val/evelink/zipball/master
sudo pip install --allow-external libffi-dev libffi-dev

export MYSQL_ROOT_PASS=poitot

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"
sudo apt-get -y install mysql-server-5.5

#check it's up
sudo mysqladmin status -p$MYSQL_ROOT_PASS

echo 'Creating databases and allianceauth user'
sudo mysqladmin -p$MYSQL_ROOT_PASS create alliance_auth 
sudo mysqladmin -p$MYSQL_ROOT_PASS create alliance_forum
sudo mysqladmin -p$MYSQL_ROOT_PASS create alliance_jabber
sudo mysqladmin -p$MYSQL_ROOT_PASS create alliance_mumble
sudo mysqladmin -p$MYSQL_ROOT_PASS create alliance_killboard

sudo mysql -u root -p$MYSQL_ROOT_PASS -e "CREATE USER 'allianceauth'@'localhost' IDENTIFIED BY 'allianceauth'"
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON * . * TO 'allianceauth'@'localhost'";
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "CREATE USER 'alliancemumble'@'localhost' IDENTIFIED BY 'alliancemumble'"
sudo mysql -u root -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON * . * TO 'alliancemumble'@'localhost'";

sudo mysqladmin -p$MYSQL_ROOT_PASS flush-privileges

sudo apt-get -y install rabbitmq-server

source /opt/allianceVenv/bin/activate
sudo pip install -r requirements.txt
deactivate

chmod +x *.sh

sudo apt-get -y install xampp

echo '--------'
echo 'Almost there!'
echo 'Next steps:\n'
echo '1. Adjust mysql root password if you feel so inclined.'
echo '2. Adjust all the stuff in ./alliance_auth/settings.py.'
echo '3. Run sudo python manage.py syncdb to set up the database tables'
echo "4. run cd /vagrant/; ./startup.sh to start, and ./shutdown.sh to stop."
echo '--------'
