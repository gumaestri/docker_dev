#!/bin/sh

#
#	function to delete the docker containers for the project
#
function killz (){
	set +e
	case "$2" in
	user-events)
		docker rm -f $DOCKERCONTAINER_USER_EVENTS || echo -e "${MINFO} killing ${DOCKERCONTAINER_USER_EVENTS}"
		docker rm -f $DOCKERCONTAINER_USER_EVENTS_FRONTEND || echo -e "${MINFO} killing ${DOCKERCONTAINER_USER_EVENTS_FRONTEND}"
		;;
	dashboard)
		docker rm -f $DOCKERCONTAINER_DASHBOARD || echo -e "${MINFO} killing ${DOCKERCONTAINER_DASHBOARD}"
		docker rm -f $DOCKERCONTAINER_DASHBOARD_FRONTEND || echo -e "${MINFO} killing ${DOCKERCONTAINER_DASHBOARD_FRONTEND}"
		;;
	mongodb)
		docker rm -f $DOCKERCONTAINER_MONGODB || echo -e "${MINFO} killing ${DOCKERCONTAINER_MONGODB}"
		;;
	openfire)
		docker rm -f $DOCKERCONTAINER_OPENFIRE || echo -e "${MINFO} killing ${DOCKERCONTAINER_OPENFIRE}"
		;;
	mysqldb)
		docker rm -f $DOCKERCONTAINER_MYSQLDB || echo -e "${MINFO} killing ${DOCKERCONTAINER_MYSQLDB}"
		;;
	nginx)
		docker rm -f $DOCKERCONTAINER_NGINX || echo -e "${MINFO} killing ${DOCKERCONTAINER_NGINX}"
		;;
	all)
		docker rm -f $DOCKERCONTAINER_OPENFIRE || echo -e "${MINFO} killing ${DOCKERCONTAINER_OPENFIRE}"
		docker rm -f $DOCKERCONTAINER_USER_EVENTS || echo -e "${MINFO} killing ${DOCKERCONTAINER_USER_EVENTS}"
		docker rm -f $DOCKERCONTAINER_USER_EVENTS_FRONTEND || echo -e "${MINFO} killing ${DOCKERCONTAINER_USER_EVENTS_FRONTEND}"
		docker rm -f $DOCKERCONTAINER_DASHBOARD || echo -e "${MINFO} killing ${DOCKERCONTAINER_DASHBOARD}"
		docker rm -f $DOCKERCONTAINER_DASHBOARD_FRONTEND || echo -e "${MINFO} killing ${DOCKERCONTAINER_DASHBOARD_FRONTEND}"
		docker rm -f $DOCKERCONTAINER_MONGODB || echo -e "${MINFO} killing ${DOCKERCONTAINER_MONGODB}"
		docker rm -f $DOCKERCONTAINER_MYSQLDB || echo -e "${MINFO} killing ${DOCKERCONTAINER_MYSQLDB}"
		docker rm -f $DOCKERCONTAINER_NGINX || echo -e "${MINFO} killing ${DOCKERCONTAINER_NGINX}"
		;;
	*)
		echo "Valid input: user-events, dashboard, openfire, mongodb, mysqldb, nginx, all"
	esac
	set -e
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi