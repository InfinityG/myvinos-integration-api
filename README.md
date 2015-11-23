# myvinos-integration-api
MyVinos Integration API

## What is it?
The API is an integration layer that provides a set of endpoints to the MyVinos mobile app, allowing VINOS credits to 
be purchased, and physical wine stock redeemed at a later stage for these credits.


## Platform and dependencies
- Ubuntu 14.04 
- Ruby 2.2.* 
- Bundler
- Sinatra
- MongoDB is the backing store

## Installation
- Development: 
    - Clone the repo from Github to your folder of choice
    - Ensure that Bundler is installed - ```gem install bundler```
    - Install dependencies - run ```bundle -install``` from the root of the project
- Test: 
    - Docker is used to create images and containers
        - For instructions on how to install Docker on Ubuntu, see the [docs](http://docs.docker.com/engine/installation/ubuntulinux/)
    - Use the Docker file in the __docker/test__ directory
    - Ruby version 2.2.1 will be installed in the image, along with other required dependencies.
    - The __test__ dockerfile creates a Docker image with a local MongoDB instance within the image.
- Production:
    - Docker is used to create images and containers
        - For instructions on how to install Docker on Ubuntu, see the [docs](http://docs.docker.com/engine/installation/ubuntulinux/)
    - The __production__ dockerfile creates a Docker image without a local MongoDB instance. In production MongoDB is 
    running in an external cluster, and is set up separately.
 
## Live environment and topology
Currently, the live environment is set up as follows:

| Name            | EC2 Name              | Instance type | Subnet  | Description                                                                                                                                 |
|-----------------|-----------------------|---------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Load balancer   | IGPROD-LB             |               |         | External interface to the internet                                                                                                          |
| NAT             | IGPROD-NAT            | m1.small      | public  | NAT server - provides external access from the private subnet; allows SSH into private subnet via ssh-agent                                 |
| Proxy           | IGPROD-PROXY          | t2.micro      | public  | Runs nginx to allow routing, port mapping and request throttling to private subnet                                                          |
| Docker server   | IGPROD-DOCKER-MYVINOS | t2.small      | private | The instance that Docker is installed on. Images and containers are installed and run from here                                             |
| Mongo primary   | IGPROD-MONGO-1        | t2.small      | private | Mongo is installed on this - this is the primary server. The database and journal lives on an attached volume (see below)                   |
| Mongo secondary | IGPROD-MONGO-2        | t2.small      | private | Mongo is installed on this - this is the primary server. The database and journal lives on an attached volume (see below)                   |
| Mongo secondary | IGPROD-MONGO3         | t2.small      | private | Mongo is installed on this - this is the primary server. The database and journal lives on an attached volume (see below)                   |
| Mongo volume 1  | IG-DATA-VOLUME-1      | 50GB volume   |         | Attached to IG-PROD-MONGO-1. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
| Mongo volume 2  | IG-DATA-VOLUME-2      | 50GB volume   |         | Attached to IG-PROD-MONGO-2. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
| Mongo volume 3  | IG-DATA-VOLUME-3      | 50GB volume   |         | Attached to IG-PROD-MONGO-3. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
|                 |                       |               |         |          

## SSL certificates
All requests to the API are made via HTTPS (SSL). The DNS is set to forward requests to the load balancer, which currently has a wildcard
 SSL certificate installed on it. Requests are then forwarded to the proxy (nginx) over HTTP, which handles the routing to the API in 
 the private subnet.