#!/bin/sh

function jenkins (){
	case "$2" in
	start)
		jenkins_start $@
		;;
	test)
		jenkins_test $@
		;;
	*)
		echo -e "${MINFO} Available options: start, test"
		exit 1
	esac
}

#start stuff for jenkins without forwarded ports
function jenkins_start (){
	case "$3" in
	user-events-backend)
		echo -e "${MINFO} Starting user-events-backend containers"
		jenkins_start_mongodb
		helper_wait_for_mongodb
		jenkins_start_user-events-backend
		;;
	*)
		echo -e "${MINFO} Available options: user-events-backend"
		exit 1
	esac
}

# script doe starting the containers isolated, running the test scrips inside and pulling the reports afterwards
function jenkins_test (){

	case "$3" in
	user-events-backend)
		jenkins_test_user-events-backend
		;;
	*)
		echo -e "${MINFO} Available options: user-events-backend"
		exit 1
	esac
}

function jenkins_test_user-events-backend (){
	cd $PROJECT_HOME
	echo "trying to run user-events-backend rspec tests..."
	set +e
	echo "copying scripts to $DOCKERCONTAINER_USER_EVENTS container"
	docker cp scripts user-events:/var/apps
	docker exec -i $DOCKERCONTAINER_USER_EVENTS /bin/bash -c "cd /var/apps;./scripts/devenv-inner test userevents all"
	set -e
	echo "trying to pull results from container $DOCKERCONTAINER_USER_EVENTS"
	mkdir -p reports/$DOCKERCONTAINER_USER_EVENTS
	docker cp $DOCKERCONTAINER_USER_EVENTS:/var/apps/reports .
}

# jenkins version, no volumes & dont exposes ports to outside (localhost)
function jenkins_start_user-events-backend (){
	local code_string="docker run --name ${DOCKERCONTAINER_USER_EVENTS} \
		--link ${DOCKERCONTAINER_MONGODB}:mongodb \
		-d ${DOCKERIMAGE_USER_EVENTS}"
	echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
	RAILSENV=$(${code_string})
	echo -e "${MINFO} Started ${DOCKERCONTAINER_USER_EVENTS} in container $RAILSENV"
}

function jenkins_start_mongodb (){
	local code_string="docker run --name ${DOCKERCONTAINER_MONGODB} \
		-e MONGODB_USER=${MONGODB_USER} -e MONGODB_PASS=${MONGODB_PWD} \
		-d ${DOCKERIMAGE_MONGODB}"
	echo -e "${MRUNNING}\n${MCSTART}${code_string}${MCEND}"
	MYSQLDB=$(${code_string})
	echo -e "${MINFO} Started ${DOCKERCONTAINER_MONGODB} in container $MYSQLDB"
}



#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi