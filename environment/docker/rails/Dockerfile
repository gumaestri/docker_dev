FROM ubuntu:latest
MAINTAINER igj@certi.org.br

#
# docker container specific stuff that takes long
#
RUN apt-get update && apt-get -y install python-setuptools openssh-server build-essential \
	&& easy_install supervisor \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# install dependencies ruby
#
RUN apt-get update && apt-get -y install curl vim htop rsync \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get update && apt-get -y install software-properties-common \
	&& apt-add-repository ppa:brightbox/ruby-ng \
	&& apt-get update \
	&& apt-get -y install ruby2.2 ruby2.2-dev \
	&& gem install bundle \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# project specific part
#
RUN apt-get update \
	&& apt-get install -y libboost-all-dev qt5-qmake qt5-default dcmtk libdcmtk2-dev \
	&& rm -rf /var/lib/apt/lists/*


RUN apt-get update \
	&& apt-get install -y git-core python-software-properties libreadline-dev libpq-dev build-essential nginx libsqlite3-0 libsqlite3-dev libxml2 libxml2-dev nodejs npm \
	&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:nginx/stable \
    && apt-get update \
  	&& apt-get install -y nginx \
  	&& rm -rf /var/lib/apt/lists/*

RUN rm -v /etc/nginx/nginx.conf
ADD configs/nginx.conf /etc/nginx/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
RUN mkdir -p /dockercache/gemcache
WORKDIR /dockercache/gemcache
ADD cache_gems/Gemfile Gemfile
ADD cache_gems/Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir -p /dockercache/npm
WORKDIR /dockercache/npm
ADD cache_npm/package.json package.json
RUN ln -s /usr/bin/nodejs /usr/bin/node && npm install


# Copy sourcecode to image (filter via .dockerignore file in git)
ADD cache_user-events /var/apps/user-events
ADD cache_user-events-frontend /var/apps/user-events-frontend

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


WORKDIR /var/apps/user-events

#
# Docker init scripts
#
ADD ./scripts/user-events.sh /user-events.sh
RUN chmod 755 /user-events.sh
ADD ./scripts/user-events-frontend.sh /user-events-frontend.sh
RUN chmod 755 /user-events-frontend.sh

ADD scripts/supervisor.sh /supervisor.sh
ADD configs/supervisord.conf /etc/supervisord.conf
RUN chmod 755 /supervisor.sh
RUN mkdir /var/log/supervisor/

EXPOSE 3000
EXPOSE 8080

ENV SECRET_KEY_BASE 659bc9c4b099fec5128e84c9ddd9a7d0903836891dd954707cb2e36fb8253aafca146724dbdcc3c56120a382445bfb7e97ffd2f1509f0635f1fea55fbca10875

# final cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/bash", "/supervisor.sh"]
