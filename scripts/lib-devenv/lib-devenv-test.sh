#!/bin/sh


#
# script for running tests asuming the whole environment is ready, e.g. inside a docker container or locally
#
function test (){
	cd $PROJECT_HOME
	echo "function test"
	mkdir -p reports

	case "$2" in
	userevents)
		echo -e "${MINFO} Running tests for server"
		test_userevents $@
		;;
	launcher)
		echo -e "${MINFO} Running tests for launcher"
		test_launcher $@
		;;
	camera)
		echo -e "${MINFO} Running tests for camera"
		test_camera $@
		;;
	chat)
		echo -e "${MINFO} Running tests for chat"
		test_chat $@
		;;
	*)
		echo -e "${MINFO} Valid input: userevents, launcher, camera, chat"
		RETVAL=1
	esac
}

function test_chat (){
	echo -e "${MINFO} function test_chat ()"
	cd dev/apps/jitsi
	ant test
}

function test_camera (){
	echo -e "${MINFO} function test_camera ()"
	cd dev/apps/webcam
	ant junit
}

function test_launcher (){
	echo -e "${MINFO} function test_launcher ()"
	cd dev/apps/launcher
	ant test
}

function test_userevents (){
	echo -e "${MINFO} function test_server ()"

	case "$3" in
		rspec)
			test_userevents_rspec $@
			;;
		rubycritic)
			test_userevents_rubycritic $@
			;;	
		all)
			test_userevents_rspec $@
			test_userevents_rubycritic
		;;
	*)
		echo -e "${MINFO} Available options: rspec, rubycritic, all"
		exit 1
	esac
}

function test_userevents_rubycritic (){
	echo -e "${MINFO} Running rubycritic now..."
	set +e
	cd $PROJECT_HOME
	cd dev/apps/user-events
	echo -e "rubycritic app --path reports/composer/rubycritic"
	rubycritic app --path reports/user-events/rubycritic
	cd $PROJECT_HOME
	mkdir -p reports/user-events
	rm -fr reports/user-events/rubycritic  > /dev/null 2>&1 || echo "deleting old rubycritic"
	mv -f dev/apps/user-events/reports/user-events/rubycritic reports/user-events
	set -e
}

function test_userevents_rspec (){
	echo -e "${MINFO} Running rspec now..."
	set +e
	cd $PROJECT_HOME
	cd dev/apps/user-events
	echo -e "COVERAGE=true bundle exec rspec spec --format progress --format documentation --out rspec.txt --format RspecJunitFormatter  --out rspec.xml"
	# COVERAGE=true triggers simplecov for coverage, config see spec/spec_helper.rb
	COVERAGE=true bundle exec rspec spec --format progress --format documentation --out rspec.txt --format RspecJunitFormatter  --out rspec.xml
	rspec_result=$(echo $?)
	cd $PROJECT_HOME
	mkdir -p reports/user-events
	rm -fr reports/user-events/coverage  > /dev/null 2>&1 || echo "deleting old coverage"
	mv -f dev/apps/user-events/coverage reports/user-events/coverage
	rm reports/user-events/rspec.txt  > /dev/null 2>&1 || echo "deleting old rspec.txt"
	rm reports/user-events/rspec.xml  > /dev/null 2>&1 || echo "deleting old rspec.xml"
	cp -f dev/apps/user-events/rspec.txt reports/user-events/rspec.txt
	cp -f dev/apps/user-events/rspec.xml reports/user-events/rspec.xml
	if [ $rspec_result != "0" ];then
		echo -e "${MWARNING} Rspec tests failed."
		exit 1
	else
		echo -e "Tests ok"
	fi
	set -e
}


#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi