#!/bin/sh


function package (){
	set -e

	cd $PROJECT_HOME
	echo -e "${MINFO} Workdir is:" + $(pwd)

	

	set +e
	case "$2" in
	server)
		DIRECTORY="deliveries/server"

		if [ -d "$DIRECTORY" ]; then
			echo "${DIRECTORY} already exists, please delete it first"
			exit 1
		fi
		package_commandcenter_dockerimages $@
		copy_scripts
		;;
	commandcenter)
		echo "THIS WILL JUST WORK ON A WINDOWS MACHINE"
		;;
	*)
		echo -e "${MINFO} Available: server"
		RETVAL=1
	esac
}

function package_commandcenter_dockerimages(){

	mkdir -p $DIRECTORY/dockerimages

	echo -e "${MINFO} Exporting all commandcenter docker images..."
	set -e
	echo -e "${MINFO} Exporting ${DOCKERIMAGE_USER_EVENTS} docker image"
	docker save $DOCKERIMAGE_USER_EVENTS > $DIRECTORY/dockerimages/$DOCKERCONTAINER_USER_EVENTS.tar

	echo -e "${MINFO} Exporting ${DOCKERIMAGE_USER_EVENTS_FRONTEND} docker image"
	docker save $DOCKERIMAGE_USER_EVENTS_FRONTEND > $DIRECTORY/dockerimages/$DOCKERCONTAINER_USER_EVENTS_FRONTEND.tar

	echo -e "${MINFO} Exporting ${DOCKERIMAGE_MONGODB} docker image"
	docker save $DOCKERIMAGE_MONGODB > $DIRECTORY/dockerimages/$DOCKERCONTAINER_MONGODB.tar

	echo -e "${MINFO} Exporting ${DOCKERIMAGE_MYSQLDB} docker image"
	docker save $DOCKERIMAGE_MYSQLDB > $DIRECTORY/dockerimages/$DOCKERCONTAINER_MYSQLDB.tar

	echo -e "${MINFO} Exporting ${DOCKERIMAGE_OPENFIRE} docker image"
	docker save $DOCKERIMAGE_OPENFIRE > $DIRECTORY/dockerimages/$DOCKERCONTAINER_OPENFIRE.tar

	echo -e "${MINFO} Exporting ${DOCKERIMAGE_NGINX} docker image"
	docker save $DOCKERIMAGE_NGINX > $DIRECTORY/dockerimages/$DOCKERCONTAINER_NGINX.tar

	echo -e "${MINFO} Exporting of docker images done"
	set +e
}

function copy_scripts(){
	mkdir -p $DIRECTORY
	mkdir -p $DIRECTORY/bin
	mkdir -p $DIRECTORY/config
	mkdir -p $DIRECTORY/init
	set -e
	cp scripts/server-installer/commandcenter.conf $DIRECTORY/init/commandcenter.conf
	cp scripts/server-installer/start-commandcenter.sh $DIRECTORY/bin/start-commandcenter.sh
	cp scripts/server-installer/stop-commandcenter.sh $DIRECTORY/bin/stop-commandcenter.sh
	cp scripts/server-installer/uninstall-commandcenter.sh $DIRECTORY/uninstall-commandcenter.sh

	cp scripts/lib-devenv/lib-devenv-config.sh $DIRECTORY/config/config.sh
	cp scripts/lib-devenv/lib-devenv-start.sh $DIRECTORY/bin/lib-start.sh
	cp scripts/lib-devenv/lib-devenv-helper.sh $DIRECTORY/bin/lib-helper.sh

	cp scripts/server-installer/install-commandcenter.sh $DIRECTORY/install-commandcenter.sh
	set +e
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi