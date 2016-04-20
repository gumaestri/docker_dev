#!/bin/bash
###################################################################
# Copyright (C) 2015 Instituto CERTI Amazonia
# All Rights Reserved
###################################################################


read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -INT $(cat tmp/pids/server.pid); exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT


#bluemix workaround because network is unreachable for ~30sec
# if [ ! -z "$CHECKSQL" ]; then
# 	echo "Workaround for BLUEMIX until network is available"
# 	echo "trying: mysqladmin -u root -p$MYSQLDB_ENV_MYSQL_ROOT_PASSWORD -h $MYSQLDB_PORT_3306_TCP_ADDR status"
# 	date
# 	until $(mysqladmin -u root -p$MYSQLDB_ENV_MYSQL_ROOT_PASSWORD -h $MYSQLDB_PORT_3306_TCP_ADDR status &> /dev/null); do
# 	    echo "."
# 	    sleep 5
# 	done
# 	date
# fi

# echo -e "\n\e[0;33mINFO:\e[0m trying: running bower"
# echo -e "\e[0;32mrake bower:install['--allow-root --config.interactive=false']\e[0m"
# rake bower:install['--allow-root --config.interactive=false'] #&> /dev/null;echo "Result $?"


# # workaound for textAngular bug https://github.com/fraywing/textAngular/issues/598
# sed -i 's/9|10/9/g' vendor/assets/bower_components/textAngular/dist/textAngular.js
# sed -i 's/9|10/9/g' vendor/assets/bower_components/textAngular/src/factories.js
# sed -i 's/9|10/9/g' vendor/assets/bower_components/textAngular/dist/textAngular.min.js


# echo -e "\n\e[0;33mINFO:\e[0m trying: to create database"
# echo -e "\e[0;32mrake db:create\e[0m"
# rake db:create #&> /dev/null;echo "Result $?"

# echo -e "\n\e[0;33mINFO:\e[0m trying: to migrate database"
# echo -e "\e[0;32mrake db:migrate\e[0m"
# rake db:migrate #&> /dev/null;echo "Result $?"

# echo -e "\n\e[0;33mINFO:\e[0m trying: to seed"
# echo -e "\e[0;32mrake db:seed\e[0m"
# rake db:seed #&> /dev/null;echo "Result $?"

# if [ -f tmp/pids/server.pid ]
# then
#     kill -INT $(cat tmp/pids/server.pid) || echo "trying to stop existing server"
#     rm tmp/pids/server.pid || echo "trying to remove old pid"
# fi
# echo -e "\n\e[0;33mINFO:\e[0m trying: rails server"
# echo -e "\e[0;32mrails s -b0.0.0.0 -p ${SERVER_PORT:-80}\e[0m"
rails s -b0.0.0.0 -p ${SERVER_PORT:-3000}