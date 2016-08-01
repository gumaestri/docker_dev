#!/bin/sh

function logs (){
	cd $PROJECT_HOME

	case "$2" in
	composer)
		echo -e "${MINFO} Running logs for composer"
		logs_composer $@
		;;
	android)
		echo -e "${MINFO} Running logs for android"
		logs_android $@
		;;
	service)
		echo -e "${MINFO} Running logs for service"
		case "$3" in
		err)
			logs_service_err $@
			;;
		out)
			logs_service_out $@
			;;
		*)
			echo -e "${MINFO} available options: err, out"
		esac
		;;
	*)
		echo -e "${MINFO} available options: composer, service, android"
	esac
}

function logs_composer (){
	cd $PROJECT_HOME
	docker exec -i sschool_composer /bin/bash -c 'cd /var/apps/dev/apps/sensible_school/log;tail -f development.log'
}

function logs_service_err (){
	cd $PROJECT_HOME
	docker exec -i sschool_service /bin/bash -c 'cd /var/apps/sschool_service;tail -f forever_err.log'
}

function logs_service_out (){
	cd $PROJECT_HOME
	docker exec -i sschool_service /bin/bash -c 'cd /var/apps/sschool_service;tail -f forever_out.log'
}

function logs_service (){
	cd $PROJECT_HOME
	docker exec -i sschool_service /bin/bash -c 'cd /var/apps/sschool_service;tail -f forever_err.log'
}

function logs_service (){
	cd $PROJECT_HOME
	docker exec -i sschool_service /bin/bash -c 'cd /var/apps/sschool_service;tail -f forever_err.log'
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi