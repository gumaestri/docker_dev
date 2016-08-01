#!/bin/bash
set -e


stop_handler() {
    start-stop-daemon --stop --pidfile /var/run/mongodb.pid --retry 4
    exit 0
}
trap 'echo "SIGTERM recieved";stop_handler' SIGTERM

mkdir -p /data/configdb /data/dbs
chown -R mongodb /data/configdb /data/dbs
start-stop-daemon --start --quiet --make-pidfile \
            --pidfile /var/run/mongodb.pid --chuid mongodb:mongodb \
            --exec "/usr/bin/mongod" &
pid="$!"

echo "start-stop-daemon PID=${pid}"

#password init
if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

wait ${pid}