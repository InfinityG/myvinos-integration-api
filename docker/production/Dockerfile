FROM ubuntu:14.04
MAINTAINER Grant Pidwell <grantpidwell@infinity-g.com>

#### General ####
RUN apt-get update && apt-get install -y curl wget git git-core curl zlib1g-dev build-essential
RUN apt-get install -y libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3
RUN apt-get install -y libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

#### Install Ruby 2.2.1, Bundler ####

# Install rbenv to install ruby
RUN git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install rbenv plugin: ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# Let's not copy gem package documentation
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install ruby
RUN rbenv install 2.1.2
RUN rbenv local 2.1.2
RUN rbenv global 2.1.2

# Install Bundler
RUN gem install bundler

#### SSH keys for Github access ####
# Ensure that the /.ssh folder is present in the root context!

RUN mkdir -p /root/.ssh
ADD /.ssh/id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

#### Clone Github repos ####

RUN mkdir -p home
RUN git clone git@github.com:InfinityG/myvinos-integration-api.git /home/myvinos-integration-api
RUN cd /home/myvinos-integration-api && \
    bundler install --without test development

### Set up working directory

WORKDIR /home/myvinos-integration-api

EXPOSE 8005

# CMD rackup
CMD ["/bin/bash"]

# To build: sudo docker build -t infinityg/myvinos-integration-api:v1 .

# To run (PRODUCTION): sudo docker run -e API_AUTH_TOKEN=* -e SHARED_AES_KEY=* -e ID_PROVIDER_PUBLIC_KEY=* -e MONGO_DB=myvinos-db -e MONGO_REPLICATED=true -e MONGO_HOST_1=*:27017 -e MONGO_HOST_2=*:27017 -e MONGO_HOST_3=*:27017 -e PRODUCT_API_KEY=* -e PRODUCT_API_SECRET=* -e PAYMENT_API_USER_ID=* -e PAYMENT_API_PASSWORD=* -e PAYMENT_API_ENTITY_ID=* -e DELIVERY_API_KEY=* -p 8005:8005 -it --rm infinityg/myvinos-integration-api:v2

# Inspect: sudo docker inspect [container_id]
# Delete all containers: sudo docker rm $(docker ps -a -q)
# Delete all images: sudo docker rmi $(docker images -q)
# Connect to running container: sudo docker exec -it [container_id] bash
# Attach to running container: sudo docker attach [container_id]
# Detach from running container without stopping process: Ctrl-p Ctrl-q
# Restart Docker service: sudo service docker.io restart