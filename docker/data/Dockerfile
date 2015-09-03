# Dockerfile for the creation of a pure Mongo DB server

FROM ubuntu:14.04
MAINTAINER Infinity-G <developer@infinity-g.com>

#### General ####

RUN apt-get update

#### Install MongoDB ####

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get update && apt-get install -y mongodb-org
RUN mkdir -p /data/db

EXPOSE 27017

CMD mongod