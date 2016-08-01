#!/bin/sh

#function to check docker user
function check_docker_user (){
	if docker ps; then
         echo "Docker user seems ok..."
    else
        echo "Incorrect Docker user, please make sure you are allowed to use Docker"
        exit 1
	fi
}

function clean (){
	case "$2" in
	images)
		clean_images @@
		;;
	containers)
		clean_containers @@
		;;
	volumes)
		clean_volumes @@
		;;
	all)
		clean_containers @@
		clean_images @@
		clean_volumes @@
		;;
	*)
		echo -e "${MINFO} Valid inutpt: images, containers, volumes, all"
		RETVAL=1
	esac
}

function clean_images(){
	#removing dangling docker images
	echo -e "${MINFO} Removing dangling images..."
	ids=`docker images -q -f dangling=true`
	if [ ! -z "$ids" ]; then
        docker rmi -f $(docker images -q -f dangling=true) || echo -e "${MINFO} Removed dangling images."
	fi
	echo -e "${MINFO} done"
}

function clean_containers(){	
	echo -e "${MINFO} Stopping any running ${APPNAME} Containers..."
	set +e
	docker rm -f $DOCKERCONTAINER_OPENFIRE > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_USER_EVENTS > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_USER_EVENTS_FRONTEND > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_MONGODB > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_MYSQLDB > /dev/null 2>&1
	docker rm -f $DOCKERCONTAINER_NGINX > /dev/null 2>&1
	set -e
	echo -e "${MINFO} done"
}

function clean_volumes(){
	echo -e "${MINFO} Removing ${APPNAME} Docker volumes..."
	set +e
	docker volume rm $DOCKERCONTAINER_USER_EVENTS_VOLUME_LOG > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_USER_EVENTS_FRONTEND_VOLUME_LOG > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_OPENFIRE_VOLUME > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_MONGODB_VOLUME_CONFIG > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_MONGODB_VOLUME_DATA > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_MYSQLDB_VOLUME_MYSQL > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_NGINX_VOLUME_LOGS > /dev/null 2>&1
	docker volume rm $DOCKERCONTAINER_NGINX_VOLUME_WWW > /dev/null 2>&1
	set -e
	echo -e "${MINFO} done"
}

function helper_wait_for_mongodb(){
	echo "=> Waiting for confirmation of MongoDB service startup"
	date
	while ! docker exec -i ${DOCKERCONTAINER_MONGODB} /bin/bash -c "mongo admin --eval "help" >/dev/null 2>&1"; do 
		echo "."
	    sleep 5
	done
	date
}

function helper_wait_for_mongodb(){
	echo "=> Waiting for confirmation of MongoDB service startup"
	date
	while ! docker exec -i ${DOCKERCONTAINER_MONGODB} /bin/bash -c "mongo admin --eval "help" >/dev/null 2>&1"; do 
		echo "."
	    sleep 5
	done
	date
}

# helper function to check the docker container status. arg $1 is should be the name
function docker_container_check (){
	CONTAINER=$1
	retval=""
	id=`docker ps -a | grep "$CONTAINER$" | awk '{print $1}'`
	if [ ! -z "$id" ]; then
        # Container CONTAINER exists"
        retval="exists"
    	# Container exists, checking status
		id=`docker ps -af status=exited | grep "$CONTAINER$" | awk '{print $1}'`
		if [ ! -z "$id" ]; then
	        # Container is exited"
	        retval="exited"
		fi
		id=`docker ps -af status=paused | grep "$CONTAINER$" | awk '{print $1}'`
		if [ ! -z "$id" ]; then
	        # Container is exited"
	        retval="paused"
		fi
		id=`docker ps -af status=running | grep "$CONTAINER$" | awk '{print $1}'`
		if [ ! -z "$id" ]; then
	        # Container is exited"
	        retval="running"
		fi
	fi
	# return result as string
	echo "$retval"
}

function stop (){
	echo -e "${MINFO} Stopping all docker containers:"
	ids=`docker ps -q`
	if [ ! -z "$ids" ]; then
        docker stop $ids
	fi
}

#
#	function to filter output to make console output more readable, flag is set by function setVerbose
#
function filteredPrint (){
	echo "$verbose"
	if [ $verbose ]
	then
	   	echo -e $1
	fi
}

#
#	helper function to set the verbose flag that is used in functon filteredPrint
#
function setVerbose (){
	if [[ $@ == *"verbose"* ]]
	then
		echo "Verbose arg detected"
	   	verbose=true
	fi
}

#
#	function to test some new developed features, just for testing purposes
#
function testscript (){
	echo "Devenv-inner here:"
	echo "$SCRIPT_HOME"
	echo "$PROJECT_HOME"
	echo "test(): total args passed to me $#"
	echo "test(): all args (\$@) passed to me -\"$@\""
	filteredPrint "test1"
	echo "always"
	filteredPrint "test2"
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi