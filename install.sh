#!/bin/bash

##########################
# global variables

tools="git bzr tar curl"

dependencies="php5 php5-curl php5-gd"

db_dependencies=""

webserver=""


##########################
clear

cd /tmp

echo "This script will automatically install a movim node on this system"

##########################
echo -e '\E[37;00m'"\033[1m\n1 - Checking required tools\n\033[0m"


tool_to_install=""
for tool in `echo $tools`
do
        hastool=`dpkg --verify $tool 2>&1`
        if [ "$hastool" = "" ]; then
                echo -e '\E[;32m'"\033[1m$tool already installed\033[0m"
        else
                echo -e '\E[;33m'"\033[1m$tool not installed\033[0m"
                echo "$tool will be installed then deleted at the end of the processus"
                tool_to_install="$tool_to_install $tool" ;
        fi
done

##########################
echo -e '\E[37;00m'"\033[1m\n2 - Database choice\n\033[0m"

echo "A movim node can be configured using different databases engines."

choice=-1
db_choice=""

while [ "$db_choice" = "" ]
do
        case "$choice" in
                "1") echo "MySQL"
                db_choice="mysql"
                db_dependencies="php5-mysql mysql-common mysql-client mysql-server"
                ;;
                "2") echo "PostgreSQL"
                db_choice="pgsql"
                db_dependencies="php5-pgsql postgresql-client postgresql-commonq postgresql-server"
                echo "Creation of the database not yet automatized, do it yourself or come back soon"
                ;;
                "3")echo "Database will not be set automatically"
                db_choice="none"
                ;;
                *)
                echo -e "\n(1) : MySQL (www.mysql.com/)"
                echo "(2) : PostgresSQL (www.postgresql.org/)"
                echo "(3) : I want to choose later"
                echo -n "Which one do you want to use ? "
                read choice
                ;;
        esac
done

##########################
echo -e '\E[37;00m'"\033[1m\n3 - Checking presence of a webserver\n\033[0m"

echo "To run Movim you need a webserver to be running"

ret=false
getent passwd www-data >/dev/null 2>&1 && ret=true

if $ret; then
    echo "User www-data exists"

        if [ -d /var/www ]; then
                echo "Directory /var/www corectly found"
        else
                echo "The directory /var/www was not found"
                echo "You probably need to install a webserver on this system"
                no_webserver=true
        fi

else
    echo "User www-data not found. This is user is needed to configure movim"
    echo "You probably need to install a webserver on this system"
    no_webserver=true
fi

if $no_webserver ; then
        echo -n "Voulez vous installer automatiquement Apache2 webserver ? [y/n] "
        echo -n "do you want to automatically install Apache2 webserver ? [y/n] "
        read answer

        if [ $answer = "y" ]; then
                webserver="apache2"
        else
                echo "Aborting installation"
                exit 1
        fi
fi

##########################
echo -e '\E[37;00m'"\033[1m\n4 - Installing packages dependencies and required tools\n\033[0m"

apt-get update
apt-get install  $webserver $db_dependencies $dependencies $tool_to_install

##########################
echo -e '\E[37;00m'"\033[1m\n5 - Downloading latest Movim code\n\033[0m"

#this line assumes the server is apahe2. Other webservers will be configured soon
website_root=`cat /etc/apache2/sites-available/000-default.conf | grep DocumentRoot | cut -f 2- -d' '`

cd $website_root # Server directory
#sudo -s -u www-data # We use the web-server user
bzr branch lp:movim # We copy the source-code from the repository

##########################
echo -e '\E[37;00m'"\033[1m\n6 - Installing Movim dependencies\n\033[0m"

cd movim
curl -sS https://getcomposer.org/installer | php
php composer.phar install


##########################
echo -e '\E[37;00m'"\033[1m\n7 - Configuring database\n\033[0m"

generated_password=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c 12 | xargs`
if [ "$db_choice" = "mysql"  ]; then
        port=3306
        statement="CREATE DATABASE movimDB ; CREATE USER 'movimAdmin'@'localhost' IDENTIFIED BY '$generated_password' ; GRANT ALL PRIVILEGES ON movimDB.* TO 'movimAdmin'@'localhost' WITH GRANT OPTION ;"

        echo -n "Enter the MySQL root password :"
        read -s mysql_root_password

        echo $statement | mysql -uroot --password="$mysql_root_password" mysql
fi
if [ "$db_choice" = "pgsql"  ]; then
        port=5432
        statement="CREATE USER movimAdmin WITH NOCREATEDB ENCRYPTED PASSWORD '$generated_password' ; CREATE DATABASE movimDB WITH OWNER = MovimAdmin"

        echo -n "Enter the PostgreSQL root password :"
        read -s pgsql_root_password

        echo $statement | mysql -uroot --password="$pgsql_root_password" mysql
fi

echo -e "<?php\n\$conf = array(\n\t'type' => '$db_choice',\n\t'username' => 'movimAdmin',\n\t'password' => '$generated_password',\n\t'host' => 'localhost',\n\t'port' => $port,\n\t'database' => 'movimDB'\n);" > $website_root/movim/config/db.inc.php


chown www-data:www-data -R $website_root/movim

##########################
echo -e '\E[37;00m'"\033[1m\n8 - Cleaning\n\033[0m"
apt-get remove $tool_to_install
