#!/bin/sh

#start function demonstation purposes
function start (){
	case "$2" in
	user-events)
		echo -e "${MINFO} Starting user-events"
		echo -e "${MINFO} Starting user-events-backend"
		start_mongodb
		sleep 5
		start_user-events-backend
		echo -e "${MINFO} Starting user-events-frontend"
		start_user-events-frontend
		;;
	user-events-backend)
		echo -e "${MINFO} Starting user-events-backend"
		start_mongodb
		sleep 5
		start_user-events-backend
		;;
	user-events-frontend)
		echo -e "${MINFO} Starting user-events-frontend"
		start_user-events-frontend
		;;
	dashboard)
		echo -e "${MINFO} Starting dashboard"
		start_mongodb
		start_mysqldb
		sleep 5
		start_dashboard-backend
		start_dashboard-frontend
		;;
	dashboard-frontend)
		echo -e "${MINFO} Starting dashboard-frontend"
		start_dashboard-frontend
		;;
	dashboard-backend)
		echo -e "${MINFO} Starting dashboard-backend"
		start_mongodb
		start_mysqldb
		sleep 5
		start_dashboard-backend
		;;
	mongodb)
		echo -e "${MINFO} Starting mongodb"
		start_mongodb
		helper_wait_for_mongodb
		;;
	server_clean)
		echo -e "${MINFO} Starting server"
		start_server_clean
		;;
	server)
		echo -e "${MINFO} Starting server"
		start_server
		;;
	openfire_clean)
		echo -e "${MINFO} Starting openfire"
		start_openfire_clean
		;;
	openfire)
		echo -e "${MINFO} Starting mysqldb"
		start_mysqldb
		echo -e "${MINFO} Starting openfire"
		start_openfire
		;;
	nginx)
		echo -e "${MINFO} Starting nginx"
		start_nginx
		;;
	mysqldb)
		echo -e "${MINFO} Starting mysqldb"
		start_mysqldb
		;;
	*)
		echo -e "${MINFO} Available options: user-events, user-events-backend, user-events-frontend, dashboard, dashboard-frontend, dashboard-backend, openfire, nginx, mongodb, mysqldb, server, server_clean"
		exit 1
	esac
}

function start_server_clean (){
	echo "Stopping any running ${APPNAME} Containers..."
	docker rm -f $DOCKERCONTAINER_OPENFIRE > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_USER_EVENTS > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_USER_EVENTS_FRONTEND > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_MONGODB > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_MYSQLDB > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_NGINX > /dev/null 2>&1
	
	start_mongodb
	sleep 3
	start_mysqldb
	echo "${MINFO} Waiting for 10 sec to give the dbs a chance to boot up"
	sleep 10
	start_user-events-backend
	sleep 3
	start_user-events-frontend
	sleep 3
	start_openfire_clean
	sleep 3
	start_nginx
}

function start_server (){
	start_mongodb
	sleep 3
	start_mysqldb
	echo "${MINFO} Waiting for 10 sec to give the dbs a chance to boot up"
	sleep 10
	start_user-events-backend
	sleep 3
	start_user-events-frontend
	sleep 3
	start_openfire
	sleep 3
	start_nginx
}

function start_nginx (){
	retval=$( docker_container_check "${DOCKERCONTAINER_NGINX}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_NGINX} existed, trying to restart"
		docker start $DOCKERCONTAINER_NGINX
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_NGINX} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_NGINX} \
		--restart=${DOCKERCONTAINER_NGINX_RESTART} \
		-v ${DOCKERCONTAINER_NGINX_VOLUME_LOGS}:/var/log/nginx \
		-v ${DOCKERCONTAINER_NGINX_VOLUME_WWW}:/var/www/html \
		-p ${DOCKERCONTAINER_NGINX_PORT}:${DOCKERCONTAINER_NGINX_PORT} \
		-d ${DOCKERIMAGE_NGINX}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_OPENFIRE} in container $RAILSENV"
	fi
}

#clean as in no databases are preconfigured and linked, for development only
function start_openfire_clean (){
	retval=$( docker_container_check "${DOCKERCONTAINER_OPENFIRE}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_OPENFIRE} existed, trying to restart"
		docker start $DOCKERCONTAINER_OPENFIRE
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_OPENFIRE} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_OPENFIRE} \
		-h openfirehost \
		--restart=${DOCKERCONTAINER_OPENFIRE_RESTART} \
		-v ${DOCKERCONTAINER_OPENFIRE_VOLUME}:/var/lib/openfire \
		${DOCKERCONTAINER_OPENFIRE_PORTS} \
		-d ${DOCKERIMAGE_OPENFIRE}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_OPENFIRE} in container $RAILSENV"
	fi
}

# this one is used in "production"
function start_openfire (){
	retval=$( docker_container_check "${DOCKERCONTAINER_OPENFIRE}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_OPENFIRE} existed, trying to restart"
		docker start $DOCKERCONTAINER_OPENFIRE
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_OPENFIRE} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		#TODO: check here, --linking in docker unneccesarily exposes root db env variable to openfire container, its saver just to pass the IP
		MYSQLDB_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysqldb)
		local code_string="docker run --name ${DOCKERCONTAINER_OPENFIRE} \
		-h openfirehost \
		-e MYSQLDB_URL=${MYSQLDB_IP} -e MYSQLDB_NAME=${OPENFIREDB_NAME} -e MYSQLDB_USER=${OPENFIREDB_USER} -e MYSQLDB_PASSWORD=${OPENFIREDB_PWD} \
		--restart=${DOCKERCONTAINER_OPENFIRE_RESTART} \
		-v ${DOCKERCONTAINER_OPENFIRE_VOLUME}:/var/lib/openfire \
		${DOCKERCONTAINER_OPENFIRE_PORTS} \
		-d ${DOCKERIMAGE_OPENFIRE} mysql"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_OPENFIRE} in container $RAILSENV"
	fi
}




function start_user-events-backend (){
	retval=$( docker_container_check "${DOCKERCONTAINER_USER_EVENTS}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_USER_EVENTS} existed, trying to restart"
		docker start $DOCKERCONTAINER_USER_EVENTS
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_USER_EVENTS} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_USER_EVENTS} \
		--restart=${DOCKERCONTAINER_USER_EVENTS_RESTART} \
		-p ${DOCKERCONTAINER_USER_EVENTS_PORT}:${DOCKERCONTAINER_USER_EVENTS_PORT} \
		-e RAILS_ENV=production \
		-v ${DOCKERCONTAINER_USER_EVENTS_VOLUME_LOG}:/var/apps/dev/apps/user-events/log \
		--link ${DOCKERCONTAINER_MONGODB}:mongodb \
		-d ${DOCKERIMAGE_USER_EVENTS}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_USER_EVENTS} in container $RAILSENV"
	fi
}

function start_user-events-frontend (){
	retval=$( docker_container_check "${DOCKERCONTAINER_USER_EVENTS_FRONTEND}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_USER_EVENTS_FRONTEND} existed, trying to restart"
		docker start $DOCKERCONTAINER_USER_EVENTS_FRONTEND
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_USER_EVENTS_FRONTEND} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_USER_EVENTS_FRONTEND} \
		--restart=${DOCKERCONTAINER_USER_EVENTS_FRONTEND_RESTART} \
		-p ${DOCKERCONTAINER_USER_EVENTS_FRONTEND_PORT}:${DOCKERCONTAINER_USER_EVENTS_FRONTEND_PORT} \
		-v ${DOCKERCONTAINER_USER_EVENTS_FRONTEND_VOLUME_LOG}:/var/log/nginx \
		-d ${DOCKERIMAGE_USER_EVENTS_FRONTEND}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_USER_EVENTS_FRONTEND} in container $RAILSENV"
	fi
}

function start_dashboard-frontend (){
	retval=$( docker_container_check "${DOCKERCONTAINER_DASHBOARD_FRONTEND}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_DASHBOARD_FRONTEND} existed, trying to restart"
		docker start $DOCKERCONTAINER_DASHBOARD_FRONTEND
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_DASHBOARD_FRONTEND} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_DASHBOARD_FRONTEND} \
		--restart=${DOCKERCONTAINER_USER_EVENTS_FRONTEND_RESTART} \
		-p ${DOCKERCONTAINER_DASHBOARD_FRONTEND_PORT}:${DOCKERCONTAINER_DASHBOARD_FRONTEND_PORT} \
		-v ${DOCKERCONTAINER_DASHBOARD_FRONTEND_VOLUME_LOG}:/var/log/nginx \
		-d ${DOCKERIMAGE_DASHBOARD_FRONTEND}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_DASHBOARD_FRONTEND} in container $RAILSENV"
	fi
}

function start_dashboard-backend (){
	retval=$( docker_container_check "${DOCKERCONTAINER_DASHBOARD}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_DASHBOARD} existed, trying to restart"
		docker start $DOCKERCONTAINER_DASHBOARD
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_DASHBOARD} already running, doing nothing"
	fi

	if [ "$retval" == "" ]
	then
		local code_string="docker run --name ${DOCKERCONTAINER_DASHBOARD} \
		--restart=${DOCKERCONTAINER_DASHBOARD_RESTART} \
		-p ${DOCKERCONTAINER_DASHBOARD_PORT}:${DOCKERCONTAINER_DASHBOARD_PORT} \
		-e RAILS_ENV=production \
		-v ${DOCKERCONTAINER_DASHBOARD_VOLUME_LOG}:/var/apps/dev/apps/dashboard/log \
		--link ${DOCKERCONTAINER_MONGODB}:mongodb --link ${DOCKERCONTAINER_MYSQLDB}:mysql \
		-d ${DOCKERIMAGE_DASHBOARD}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		RAILSENV=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_DASHBOARD} in container $RAILSENV"
	fi
}

function start_mongodb (){
	retval=$( docker_container_check "${DOCKERCONTAINER_MONGODB}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_MONGODB} already exists, trying to resume from existed state"
		docker start $DOCKERCONTAINER_MONGODB
	fi

	if [ "$retval" == "" ]
	then
		# -v ${DOCKERCONTAINER_MONGODB}_config:/data/configdb
		# -v ${DOCKERCONTAINER_MONGODB}_db:/data/db
		local code_string="docker run --name ${DOCKERCONTAINER_MONGODB} \
		--restart=on-failure:10 \
		-e MONGODB_USER=${MONGODB_USER} -e MONGODB_PASS=${MONGODB_PWD} \
		-v ${DOCKERCONTAINER_MONGODB_VOLUME_CONFIG}:/data/configdb -v ${DOCKERCONTAINER_MONGODB_VOLUME_DATA}:/data/db \
		-p 27018:27017 \
		-d ${DOCKERIMAGE_MONGODB}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		MYSQLDB=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_MONGODB} in container $MYSQLDB"
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_MONGODB} already running, doing nothing"
	fi
}


function start_mysqldb (){
	retval=$( docker_container_check "${DOCKERCONTAINER_MYSQLDB}" )
	if [ "$retval" == "exited" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_MYSQLDB} already exists, trying to resume from existed state"
		docker start $DOCKERCONTAINER_MYSQLDB
	fi

	if [ "$retval" == "" ]
	then
		# -v /tmp/mysql_datadir:/var/lib/mysql
		local code_string="docker run --name ${DOCKERCONTAINER_MYSQLDB} \
		--restart=on-failure:10 \
		-v ${DOCKERCONTAINER_MYSQLDB_VOLUME_MYSQL}:/var/lib/mysql \
		-p 3307:3306 \
		-e OPENFIREDB_INIT=true -e OPENFIREDB_NAME=${OPENFIREDB_NAME} -e OPENFIREDB_USER=${OPENFIREDB_USER} -e OPENFIREDB_PWD=${OPENFIREDB_PWD} -e MYSQL_ROOT_PASSWORD=${DOCKERCONTAINER_MYSQLDB_ROOT_PWD} \
		-d ${DOCKERIMAGE_MYSQLDB}"
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		MYSQLDB=$(${code_string})
		echo -e "${MINFO} Started ${DOCKERCONTAINER_MYSQLDB} in container $MYSQLDB"
	fi

	if [ "$retval" == "running" ]
	then
		echo -e "${MINFO} ${DOCKERCONTAINER_MYSQLDB} already running, doing nothing"
	fi
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi