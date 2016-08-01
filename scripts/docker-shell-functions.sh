#!/bin/bash
###################################################################
# Copyright (C) 2015 Instituto CERTI Amazonia
# All Rights Reserved
###################################################################


echo "dcleanimages"
function dcleanimages {
  docker rmi -f $(docker images -q -f dangling=true)
}

echo "dcleancontainers"
function dcleancontainers {
  docker rm -v `docker ps -a -q -f status=exited`
}
