#!/bin/sh

function build (){
	cd $PROJECT_HOME
	echo -e "${MINFO} Workdir is:" + $(pwd)

	case "$2" in
	rails)
		build_railss @@
		;;
	mysqldb)
		build_mysqldb @@
		;;
	mongodb)
		build_mongodb @@
		;;
	all)
		build_all @@
		;;
	*)
		echo -e "${MINFO} Valid inutpt: rails, mysqldb, mongodb,all"
		RETVAL=1
	esac
	echo -e "${MINFO} Building Docker Images done"
}


function build_all(){
	echo -e "${MINFO} Building all server docker containers"
	build_user-events-backend @@
	build_user-events-frontend @@
	build_dashboard-backend @@
	build_dashboard-frontend @@
	build_openfire @@
	build_nginx @@
	build_mysqldb @@
	build_mongodb @@
}

function build_rails(){
	echo -e "${MINFO} Building rails container"
	#
	# copy dependencies for caching
	#
	set +e
	mkdir -p config/environment/docker/rails/cache_gems
	cmp dev/apps/rails/Gemfile config/environment/docker/rails/cache_gems/Gemfile
  || cp -Rvf dev/apps/rails/Gemfile config/environment/docker/rails/cache_gems/Gemfile
	cmp dev/apps/rails/Gemfile.lock
  config/environment/docker/rails/cache_gems/Gemfile.lock || cp -Rvf
  dev/apps/rails/Gemfile.lock config/environment/docker/rails/cache_gems/Gemfile.lock

	#
	#copy the code
	#
	rm -fr config/environment/docker/server/cache_rails;rsync --delete -av
  dev/apps/rails/ config/environment/docker/rails/cache_rails --exclude attachments --exclude tmp
	
	set -e
	# actual server build
	docker build -t $DOCKERIMAGE_RAILS config/environment/docker/rails
}

function build_mongodb(){
	echo -e "${MINFO} Building mongodb container"
	#
	# build mongodn container
	#
	docker build -t $DOCKERIMAGE_MONGODB config/environment/docker/mongodb
}

function build_mysqldb(){
	echo -e "${MINFO} Building mysqldb container"
	#
	# build MYSQLDB container
	#
	docker build -t $DOCKERIMAGE_MYSQLDB config/environment/docker/mysqldb
}

#nothing should be exectured in this "function library" but who knows...
main() {
	echo "lib main"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
