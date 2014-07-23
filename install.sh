#!/bin/bash

clear

cd /tmp

echo "This script will automatically install a movim node on this system"
echo -e '\E[37;00m'"\033[1m\n1 - Checking required tools\n\033[0m"

tools="git bzr tar curl"
for tool in `echo $tools`
do
        hastool=`dpkg --verify $tool 2>&1`
        if [ "$hastool" = "" ]; then
                echo -e '\E[;32m'"\033[1m$tool already installed\033[0m"
        else
                echo -e '\E[;33m'"\033[1m$tool not installed\033[0m"
                echo "$tool will be installed then deleted at the end of the processus"
        fi
done

echo -e '\E[37;00m'"\033[1m\n2 - Database choice\n\033[0m"

echo "A movim node can be configured using different databases engines."

choice=-1
dbchoice=""

while [ "$dbchoice" = "" ]
do
        case "$choice" in
                "1") echo "MySQL"
                dbchoice="MySQL"
                ;;
                "2") echo "PostgreSQL"
                dbchoice="PostgreSQL"
                ;;
                "3")echo "Database will not be set automatically"
                dbchoice="none"
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

echo -e '\E[37;00m'"\033[1m\n4 - Checking presence of a webserver\n\033[0m"

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
                echo -e "\nAborting installation"
        fi

else
    echo "User www-data not found. This is user is needed to configure movim"
    echo "You probably need to install a webserver on this system"
fi

echo -e '\E[37;00m'"\033[1m\n3 - Installing packages dependencies and required tools\n\033[0m"

echo -e '\E[37;00m'"\033[1m\n4 - Downloading latest Movim code\n\033[0m"

echo -e '\E[37;00m'"\033[1m\n6 - Installing Movim dependencies\n\033[0m"

echo -e '\E[37;00m'"\033[1m\n7 - Configuring database\n\033[0m"

echo -e '\E[37;00m'"\033[1m\n8 - Cleaning\n\033[0m"
