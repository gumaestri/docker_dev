#!/bin/sh



#
# function dev is intended for developers to be aber to work on code with shared project folders
#
function dev (){
	case "$2" in
  rails)
    echo -e "${MINFO} Starting Rails containers"
    start_mysqldb
    sleep 3
    echo -e "${MINFO} Starting"
    local code_string='docker run --name '$DOCKERCONTAINER_USER_EVENTS' -it
    --publish 3000:3000 --link '$DOCKERCONTAINER_MONGODB':mongodb --volume
    '$PROJECT_HOME':/var/apps --entrypoint="/bin/bash" '$DOCKERIMAGE_USER_EVENTS
    echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"echo -e "${MWARNING}
    /var/apps is SHARED by a volume with your host. BE AWARE that this can have
    side effects."echo -e "${MWARNING} Docker Container is uses
    --entrypoint=\"/bin/bash\"."echo -e "${MCSTART}/rails.sh${MCEND}"
    echo -e ""
    ${code_string}
    ;;
  *)
	rails-mongo)
		echo -e "${MINFO} Starting Rails Mongo containers"
		start_mongodb
		sleep 3
		echo -e "${MINFO} Starting"
		local code_string='docker run --name '$DOCKERCONTAINER_USER_EVENTS' -it --publish 3000:3000 --link '$DOCKERCONTAINER_MONGODB':mongodb --volume '$PROJECT_HOME':/var/apps --entrypoint="/bin/bash" '$DOCKERIMAGE_USER_EVENTS
		echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
		echo -e "${MWARNING} /var/apps is SHARED by a volume with your host. BE AWARE that this can have side effects."
		echo -e "${MWARNING} Docker Container is uses --entrypoint=\"/bin/bash\"."
		echo -e "${MCSTART}/rails.sh${MCEND}"
		echo -e ""
		${code_string}
		;;
	*)
		echo -e "${MWARNING} What do you want to develop? Valid options: rails,
    rails-mongo"
		exit 1
	esac
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
