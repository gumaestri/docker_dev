#!/bin/bash

echo "Safeguard to wait until mongo Database is available"
CHECK="curl -s ${MONGODB_PORT_27017_TCP_ADDR}:${MONGODB_PORT_27017_TCP_PORT}"
echo "trying: ${CHECK}"
date
while ! $CHECK; do 
	echo "."
    sleep 5
done
date


stop_handler() {
    kill $pid
    exit 0
}

trap 'echo "SIGTERM recieved";stop_handler' SIGTERM

cd /var/apps/dev/apps/rails
rails s -b0.0.0.0 -p ${SERVER_PORT:-3000} &

pid="$!"
echo "start-stop-daemon PID=${pid}"

wait ${pid}
