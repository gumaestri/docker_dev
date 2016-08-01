FROM ubuntu:16.04

#
# install dependencies ruby & gems
# build-essential is for build native extensions
# zlib1g-dev is a dependency of rails
#
RUN apt-get update && apt-get -y install ruby=1:2.3.0\* ruby-dev=1:2.3.0\* \
	&& apt-get -y install build-essential=12.1\* zlib1g-dev=1:1.2.8\* \
	&& gem install bundler -v 1.12.5 \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
# dependency for startupscript
RUN apt-get update && apt-get -y install curl=7.47.0\* && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
RUN mkdir -p /dockercache/gemcache
WORKDIR /dockercache/gemcache
ADD cache_gems/Gemfile Gemfile
ADD cache_gems/Gemfile.lock Gemfile.lock
RUN bundle install

# Copy sourcecode to image (filter via .dockerignore file in git)
ADD cache_rails /var/apps/dev/apps/rails

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /var/apps/dev/apps/rails

#
# Docker init scripts
#
ADD ./scripts/rails.sh /rails.sh
RUN chmod 755 /rails.sh

EXPOSE 3000

ENV SECRET_KEY_BASE 659bc9c4b099fec5128e84c9ddd9a7d0903836891dd954707cb2e36fb8253aafca146724dbdcc3c56120a382445bfb7e97ffd2f1509f0635f1fea55fbca10875

VOLUME /var/apps/dev/apps/rails/log

# final cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/rails.sh"]
