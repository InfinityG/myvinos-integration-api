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
- An external installation of [ID-IO](https://github.com/InfinityG/id-io) - an open-source identity provider  

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
Currently, the live environment is set up in Amazon AWS, via the EC2 dashboard. No automated deployment scripts have yet been 
 created. Access to these instances must be made via SSH, and require the relevant SSH keys. 
 
 The list of instances are as follows:

| Name            | EC2 Name              | Instance type | Subnet  | Description                                                                                                                                 |
|-----------------|-----------------------|---------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Load balancer   | IGPROD-LB             |               |         | External interface to the internet                                                                                                          |
| NAT             | IGPROD-NAT            | m1.small      | public  | NAT server - provides external access from the private subnet; also a 'bastion' server that allows SSH into private subnet via ssh-agent    |
| Proxy           | IGPROD-PROXY          | t2.micro      | public  | Runs nginx to allow routing, port mapping and request throttling to private subnet                                                          |
| Docker server   | IGPROD-DOCKER-MYVINOS | t2.small      | private | The instance that Docker is installed on. Images and containers are installed and run from here                                             |
| Mongo primary   | IGPROD-MONGO-1        | t2.small      | private | Mongo is installed on this - this is the primary server. The database and journal lives on an attached volume (see below)                   |
| Mongo secondary | IGPROD-MONGO-2        | t2.small      | private | Mongo is installed on this - this is a secondary server. The database and journal lives on an attached volume (see below)                   |
| Mongo secondary | IGPROD-MONGO3         | t2.small      | private | Mongo is installed on this - this is a secondary server. The database and journal lives on an attached volume (see below)                   |
| Mongo volume 1  | IG-DATA-VOLUME-1      | 50GB volume   |         | Attached to IG-PROD-MONGO-1. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
| Mongo volume 2  | IG-DATA-VOLUME-2      | 50GB volume   |         | Attached to IG-PROD-MONGO-2. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
| Mongo volume 3  | IG-DATA-VOLUME-3      | 50GB volume   |         | Attached to IG-PROD-MONGO-3. This is the volume that the journal and database runs on. Backups can be made off this via creating snapshots. |
|                 |                       |               |         |          

## SSL certificates
All requests to the API are made via HTTPS (SSL). The DNS is set to forward requests to the load balancer, which currently has a wildcard
 SSL certificate installed on it. Requests are then forwarded to the proxy (nginx) over HTTP, which handles the routing to the API in 
 the private subnet.
 
## Endpoints

### ID-IO

An external identity provider, ID-IO, is used to authenticate registered users. The endpoints for this are listed below:

| Operation          | Description                            | Endpoint            | Headers | Request | Response |
|--------------------|----------------------------------------|---------------------|---------|---------|----------|
| Registration       | Register a user                        | /users [POST]       | none    |         |          |
| Login              | Login and generate an ID-IO auth token | /login [POST]       | none    |         |          |
| Forgotten password | Initiate OTP for forgotten password    | /users/otp [POST]   | none    |         |          |
|                    | Complete forgotten password flow       | /users/reset [POST] | none    |         |          |                                                                                                                                                                                                                                              |                                                                                                                                             |

### MyVinos API

| Operation                              | Description                                                                                                  | Endpoint                | Headers                | Samples |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------|-------------------------|------------------------|---------|
| Get products                           | Gets the list of products                                                                                    | /products [GET]         | none                   |[sample](#get-products)         |
| Create access token                    | Creates an access token                                                                                      | /tokens  [POST]         | none                   |[sample](#create-access-token)|
| Create an order to purchase VINOS      | Create an order to purchase VINOS credits                                                                    | /orders [POST]          | Authorization:[token]  |[sample](#create-an-order-to-purchase-vinos)|
| Create an order to purchase membership | Create an order to purchase a membership                                                                     | /orders [POST]          | Authorization:[token]  |[sample](#create-an-order-to-purchase-membership)|
| Create an order to redeem VINOS        | Create an order to redeem VINOS for physical items. Request also contains location information for delivery. | /orders [POST]          | Authorization: [token] |[sample](#create-an-order-to-redeem-vinos-for-physical-products)|
| Get user details                       | Get the details for a particular user                                                                        | /users/{username} [GET] | Authorization: [token] |[sample](#get-user-details)|

#### Get products

Uri: ```/products```

Method: GET
Headers: none

__Sample response:__

```
[
{
    "categories": [
        {
            "categories": [
                {
                    "categories": [],
                    "description": "",
                    "id": "55f832e7b85a5414e700004b",
                    "image_url": "",
                    "name": "Reserve Wines",
                    "slug": "reserve-wines"
                }
            ],
            "description": "",
            "id": "55f832e7b85a5414e7000048",
            "image_url": "",
            "name": "Cellar Collections",
            "slug": "collections"
        },
        {
            "categories": [
                {
                    "categories": [],
                    "description": "",
                    "id": "55f832e7b85a5414e700004c",
                    "image_url": "",
                    "name": "White",
                    "slug": "white"
                }
            ],
            "description": "",
            "id": "55f832e7b85a5414e7000049",
            "image_url": "",
            "name": "Wine Types",
            "slug": "winetypes"
        },
        {
            "categories": [
                {
                    "categories": [
                        {
                            "categories": [],
                            "description": "",
                            "id": "55f832e7b85a5414e700004e",
                            "image_url": "https://myvinos.club/wp-content/uploads/2015/03/talkwine3.png",
                            "name": "Wine Geeks",
                            "slug": "wine-geeks"
                        }
                    ],
                    "description": "",
                    "id": "55f832e7b85a5414e700004d",
                    "image_url": "",
                    "name": "I'm in the mood for...",
                    "slug": "moods"
                }
            ],
            "description": "",
            "id": "55f832e7b85a5414e700004a",
            "image_url": "",
            "name": "Cellar Filters",
            "slug": "cellar-filters"
        }
    ],
    "currency": "VINOS",
    "description": "<p>Rocking Horse is our cornerstone wine....</p>\n",
    "id": "55f832e7b85a5414e7000003",
    "image_url": "https://myvinos.club/wp-content/uploads/2015/09/ThorneDaughters_RockingHorse_Pinotage2013.jpg",
    "name": "Thorne and Daughters Rocking Horse (2014)",
    "price": "25",
    "product_id": 72320,
    "product_type": "Wine",
    "tags": {
        "grapes": "White blend",
        "style": "fresh and delicate",
        "region": "Elgin",
        "producer": "Thorne and Daughters",
        "score_1": null,
        "score_2": null,
        "score_3": null
    }
},
   ...
]

```

#### Create access token 

Uri: ```/tokens```

Method: POST
Headers: none

__Sample request:__

```
{
  "auth":"gvZWzBj7zrbTovwCDutSIv4vQVENi0HcyGvQp6yLCSUjgi2lIpgr3BUfiqzr\n3SV4HXznIzrIctgek60V0TGOaS/ZcF6Ikl5RLPSRlb5dgOA/r2fewZk5cdnA\n5C6qE+1zjko+wwiSqNCDadXGGHOEMWo/yDvR+SKjEYmoiE24yQd1mNk6EFRC\nazf1yhDHe5Hghi9x6Zl8WbwZ++KDkWdLRO43/qhOy3tr34O0KiNNX2ERH60G\nv27wiAp5nvFjXHdWHN8qlVg8oWfUe8bce7/IF6T8qPP9WCYAFuoyO9sGbrET\n9Qw08/8fnSQ3RbUW5twqhSW7XFeMXwuIwk5U3IBsiHpuKX3lKLYSqGiFzZOT\niQ1M1sF0UW3ULpKQ1KG/1Rlr7N8CS2hwapXKlri8uMKLIleEQPPoURpHrusW\nz4dXHb6/CW2QinqbbhrA0WRBAE0dWknjE/jL18CHrYDWM2vCY4S2Qk4P5rWd\nUSZlWw/UBFow6PIaJpCebTI9S3kwmA3MkVRoRKksX3ZYo+i144KKOv69LUgt\nj1+S+J+k5Qo2bSslrODg1OpY2cX3HTg+2wsChGPSB3MRS2+cjEnnhmHjq0yI\n6iD8NWaWcL/OktDWEaU=\n",
  "iv":"EHoV2Y2hEOr93QXt0c9o5w==\n"
}
```

__Sample response:__

```
{"token":"dd579963-3e49-4dbf-9160-c521625f3c52"}
```

#### Create an order to purchase VINOS

Uri: ```/orders```

Method: POST
Headers: Authorization: [token]

__Sample request:__

```
{
    "type": "vin_purchase",
    "products": [
        {
            "product_id": "71227",
            "quantity": 1
        }
    ]
}
```

__Sample response:__

```
{
    "id": "55e98e9fb85a541170000004",
    "status": "pending",
    "checkout_id": "0941A83E2D5F8C0089F85C975DEE6A95.sbg-vm-tx01",
    "checkout_uri": "https://test.oppwa.com/v1/paymentWidgets.js?checkoutId="
}
```

#### Create an order to purchase membership

Uri: ```/orders```

Method: POST
Headers: Authorization: [token]

__Sample request:__

```
{
    "type": "mem_purchase",
    "products": [
        {
            "product_id": "71227",
            "quantity": 1
        }
    ]
}
```

__Sample response:__

```
{
    "id": "55e98e9fb85a541170000004",
    "status": "pending",
    "checkout_id": "0941A83E2D5F8C0089F85C975DEE6A95.sbg-vm-tx01",
    "checkout_uri": "https://test.oppwa.com/v1/paymentWidgets.js?checkoutId="
}

OR
(for situations where no payment is required due to high enough balance)

{
    "id": "55e98e9fb85a541170000004",
    "status": "complete"
}

```

#### Create an order to redeem VINOS for physical products

Uri: ```/orders```

Method: POST
Headers: Authorization: [token]

__Sample request:__

```
{
    "type": "vin_redemption",
    "products": [
        {
            "product_id": "71594",
            "quantity": 1
        }
    ],
    "location": {
        "address": "12 ajax way, pinelands, cape town 7405",
        "coordinates": "-33.926401, 18.444876"
    },
    "notes":"Blue roof"
}
```

__Sample response:__

```
{
    "id": "4234",
    "status": "complete",
    "delivery_details": {
        "distance_estimate": 4082,
        "message": "delivery placed",
        "price": 35,
        "time_estimate": 520
    },
    "balance": "120"
}
```

#### Get user details


Uri: ```/users/{username}```

Method: GET
Headers: Authorization: [token]

__Sample response:__

```
{
    "id": "",
    "external_id": "",
    "third_party_id": "",
    "username": "johnny_mnemonic@test.com",
    "first_name": "Johnny",
    "last_name": "Mnemonic",
    "email": "johnny_mnemonic@test.com",
    "balance": "75",
    "pending_balance":"0",
    "membership_type":"basic",
    "cards":[]
}
```