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
- External APIs: 
    - [ID-IO](https://github.com/InfinityG/id-io) - an open-source identity provider which provides a registration and authentication service
    - [WooCommerce API](http://woothemes.github.io/woocommerce-rest-api-docs/) (for integration with stock management and order placement)
    - [Wumdrop API](https://wumdrop.readme.io/docs) (for integration with 3rd party delivery service)
    - [Peach Payments API](https://peachpayments.docs.oppwa.com/) (for integration with 3rd party payment provider)

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
    - CREATE THE DOCKERFILE ON THE INSTANCE:
        - Create a Dockerfile ```sudo nano Dockerfile``` in the folder of your choice, and copy the text of the sample Dockerfile in the 
        docker/production/Dockerfile into it.
    - CREATE AN IMAGE:
        - Run the following docker command from the root of the folder (this will create the image):
        ```
        sudo docker build -t infinityg/myvinos-integration-api:v1 .
        ```
    - STARTING A CONTAINER:
        - After creation of an image using the Dockerfile, start a container as follows (where the '-e' are environment variables required by the application; '-p' is the port mapping):
    
        ```
        sudo docker run -e API_AUTH_TOKEN=**** 
        -e SHARED_AES_KEY=**** 
        -e ID_PROVIDER_PUBLIC_KEY=**** 
        -e MONGO_DB=myvinos-db 
        -e MONGO_REPLICATED=true 
        -e MONGO_HOST_1=10.0.1.28:27017 
        -e MONGO_HOST_2=10.0.1.228:27017 
        -e MONGO_HOST_3=10.0.1.238:27017 
        -e PRODUCT_API_KEY=**** 
        -e PRODUCT_API_SECRET=**** 
        -e PAYMENT_API_USER_ID=**** 
        -e PAYMENT_API_PASSWORD=**** 
        -e PAYMENT_API_ENTITY_ID=**** 
        -e DELIVERY_API_KEY=**** 
        -e FORCE_ASCII_CONVERSION=true 
        -p 8005:8005 -it --rm infinityg/myvinos-integration-api:v2
        
        ```
    
        The key to the above environment variables is as follows:
        
        | Environment variable   | Description                                                                                                                                                                                |
        |------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
        | API_AUTH_TOKEN         | The API administrative key                                                                                                                                                                 |
        | SHARED_AES_KEY         | The AES key shared with the identity provider (ID-IO), and used to encrypt auth tokens which are used by MyVinos API                                                                       |
        | ID_PROVIDER_PUBLIC_KEY | The identity provider's (ID-IO) public ECDSA key, used by MyVinos API to validate the signature generated by ID-IO and embedded in the auth token. This ensures the validity of the token. |
        | MONGO_DB               | (String) The name of the MongoDB database                                                                                                                                                  |
        | MONGO_REPLICATED       | (Boolean) Indicates whether a MongoDB replica set is used                                                                                                                                  |
        | MONGO_HOST_1           | (String) Host 1 in the replica set                                                                                                                                                         |
        | MONGO_HOST_2           | (String) Host 2 in the replica set                                                                                                                                                         |
        | MONGO_HOST_3           | (String) Host 3 in the replica set                                                                                                                                                         |
        | PRODUCT_API_KEY        | (String) The key used to connect to the WooCommerce API                                                                                                                                    |
        | PRODUCT_API_SECRET     | (String) The secret used to connect to the WooCommerce API                                                                                                                                 |
        | PAYMENT_API_USER_ID    | (String) The user id of the Peach Payments API                                                                                                                                             |
        | PAYMENT_API_PASSWORD   | (String) The password used to connect to the Peach Payments API                                                                                                                            |
        | PAYMENT_API_ENTITY_ID  | (String) The entity ID used to connect to the Peach Payments API                                                                                                                           |
        | DELIVERY_API_KEY       | (String) The API key used to connect to Wumdrop                                                                                                                                            |
        | FORCE_ASCII_CONVERSION | (Boolean) Forces ASCII to UTF8 conversion on JSON requests                                                                                                                                 |

## Endpoints

### ID-IO

An external identity provider, ID-IO, is used to authenticate registered users. The endpoints for this are listed below:

| Operation          | Description                            | Endpoint            | Headers | Request | Response |
|--------------------|----------------------------------------|---------------------|---------|---------|----------|
| Registration       | Register a user                        | /users [POST]       | none    |         |          |
| Login              | Login and generate an ID-IO auth token | /login [POST]       | none    |         |          |
| Forgotten password | Initiate OTP for forgotten password    | /users/otp [POST]   | none    |         |          |
|                    | Complete forgotten password flow       | /users/reset [POST] | none    |         |          |                                                                                                                                                                                                                                              
                                                                                                                                            
                                                                                                                                             
### MyVinos API

| Operation                              | Type         | Description                                                                                                  | Endpoint                           | Headers                | Samples |
|----------------------------------------|--------------|--------------------------------------------------------------------------------------------------------------|------------------------------------|------------------------|---------|
| Get products                           | Standard     | Gets the list of products                                                                                    | /products [GET]                    | none                   |[sample](#get-products)         |
| Create access token                    | Standard     | Creates an access token, using the auth payload generated by logging into ID-IO (see above)                  | /tokens  [POST]                    | none                   |[sample](#create-access-token)|
| Create an order to purchase VINOS      | Standard     | Create an order to purchase VINOS credits                                                                    | /orders [POST]                     | Authorization:[token]  |[sample](#create-an-order-to-purchase-vinos)|
| Create an order to purchase membership | Standard     | Create an order to purchase a membership                                                                     | /orders [POST]                     | Authorization:[token]  |[sample](#create-an-order-to-purchase-membership)|
| Create an order to redeem VINOS        | Standard     | Create an order to redeem VINOS for physical items. Request also contains location information for delivery. | /orders [POST]                     | Authorization:[token]  |[sample](#create-an-order-to-redeem-vinos-for-physical-products)|
| Get order list for user                | Standard     | Get a list of orders for a user                                                                              | /orders [GET]                      | Authorization:[token]  |[sample](#get-list-of-orders-for-a-user)|
| Get user details                       | Standard     | Get the details for a particular user                                                                        | /users/{username} [GET]            | Authorization:[token]  |[sample](#get-user-details)|
| Create an order to credit VINOS        | __Admin__    | Create an order to credit VINOS to a user                                                                    | /admin/orders [POST]               | Authorization:[token]  |[sample](#admin-create-an-order-to-credit-vinos-to-a-user)|
| Get user list                          | __Admin__    | Get a list of users                                                                                          | /admin/users [GET]                 | Authorization:[token]  |[TODO]|
| Get all orders                         | __Admin__    | Get a list of all orders (filtered)                                                                          | /admin/orders [GET]                | Authorization:[token]  |[sample](#admin-get-all-orders-filtered)|

#### Get products

- Uri: ```/products```
- Method: GET
- Headers: none

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

Prerequisite: an auth payload must be generated via the ID-IO identity provider first. This payload is then sent in its entirety 
to the endpoint below. 

- Uri: ```/tokens```
- Method: POST
- Headers: none

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

- Uri: ```/orders```
- Method: POST
- Headers: 
    - Authorization: [token] __required__

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

- Uri: ```/orders```
- Method: POST
- Headers: 
    - Authorization: [token] __required__

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

- Uri: ```/orders```
- Method: POST
- Headers: 
    - Authorization: [token] __required__

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

#### Get list of orders for a user

- Uri: ```/orders```
    - Optional querystring parameters - eg: ```/orders?offset=2&limit=10&type=vin_purchase```
        - ```offset``` is used for paging and represents the page number
        - ```limit``` is used for paging and represents the page record length
        - ```type``` filters by order type (```vin_purchase```, ```vin_redemption```, ```mem_purchase```, ```vin_credit```)
- Method: GET
- Headers: 
    - Authorization: [token] __required__
    - Accept: ```application/json``` OR ```text/csv``` (optional - will default to ```application/json```)

__Sample response (JSON):__

```
[
    {
        "type": "vin_purchase",
        "user_id": "12312",
        "external_order_id": null,
        "transaction": {
            "type": "vin_redemption",
            "external_transaction_id": "2132112",
            "checkout_id": "F095C2157ADD02050ABA6DCBB065D046.sbg-vm-tx01",
            "amount": "1000",
            "currency": "ZAR",
            "status": "complete"
        },
        "delivery": null,
        "products": [
            {
                "product_id": 71227,
                "product_type": "Top-up",
                "supplier": "MyVinos",
                "producer": null,
                "price": "100",
                "currency": "ZAR",
                "name": "VINOS Top-up: R1,000",
                "description": "",
                "image_url": "https://myvinos.club/wp-content/uploads/2015/04/VinosInvest-Gold.png",
                "tags": {
                    "color": null,
                    "grapes": [],
                    "style": [],
                    "mood": []
                }
            }
        ]
    }
]
```

#### Get user details

- Uri: ```/users/{username}```
- Method: GET
- Headers: 
    - Authorization: [token] __required__

__Sample response:__

```
{
    "balance": 35,
    "created_at": "2015-11-06T20:19:19.057Z",
    "email": "johnny_mnemonic@test.com",
    "external_id": "563cfdb9b85a5433b200008f",
    "first_name": "Johnny",
    "id": "563d0b47b85a5435fd000001",
    "last_name": "Mnemonic",
    "membership_type": "silver",
    "pending_balance": 0,
    "third_party_id": "738",
    "updated_at": "2015-11-20T11:31:45.233Z",
    "username": "johnny_mnemonic@test.com",
    "cards": [
        {
            "default": true,
            "expiry_month": 12,
            "expiry_year": 2016,
            "holder": "Johnny Mnemonic",
            "id": "564df1b3b85a54113c000298",
            "last_4_digits": 1111
        }
    ]
}
```

#### ADMIN: Create an order to credit VINOS to a user

- Uri: ```/admin/orders```
- Method: POST
- Headers: 
    - Authorization: [token] __required__

The authorization token must be of an admin user. The product in the product list must be a VINOS top-up product.

__Sample request:__

```
{
    "type": "vin_credit",
    "username":"johnny_bravo@test.com",
    "products": [
        {
            "product_id": "72360",
            "quantity": 1
        }
    ]
}
```

__Sample response:__

```
{
    "id": "4234",
    "status": "complete"
    "balance": "120"
}
```

#### ADMIN: Get all orders (filtered)

- Uri: ```/admin/orders```
    - Optional querystring parameters - eg: ```/orders?offset=1&limit=2&type=vin_credit&username=johnny_bravo@test.com```
        - ```offset``` is used for paging and represents the page number
        - ```limit``` is used for paging and represents the page record length
        - ```type``` filters by order type (```vin_purchase```, ```vin_redemption```, ```mem_purchase```, ```vin_credit```)
    - ```username``` filters by a particular username
- Method: GET
- Headers: 
    - Authorization: [token] __required__
    - Accept: ```application/json``` OR ```text/csv``` (optional - will default to ```application/json```)

The authorization token must be of an admin user. 

__Sample response (JSON):__

```
[
    {
        "created_at": "2015-12-17T16:02:52.609Z",
        "delivery": null,
        "id": "5672dcacb85a54415b000292",
        "products": [
            {
                "categories": [],
                "description": "",
                "id": "5672dcacb85a54415b000293",
                "name": "VINOS Reward 5",
                "price": "5",
                "product_id": "72360",
                "quantity": 1,
                "tags": {}
            }
        ],
        "transaction": {
            "amount": "5",
            "created_at": "2015-12-17T16:02:52.613Z",
            "currency": "VINOS",
            "id": "5672dcacb85a54415b000291",
            "memo": "vinos credit",
            "status": "complete",
            "type": "vin_credit",
            "updated_at": "2015-12-17T16:02:52.613Z"
        },
        "type": "vin_credit",
        "updated_at": "2015-12-17T16:02:52.609Z",
        "user_id": "563d0b47b85a5435fd000001"
    },
    {
        "created_at": "2015-12-17T15:58:39.859Z",
        "delivery": null,
        "id": "5672dbafb85a544148000002",
        "products": [
            {
                "categories": [],
                "description": "",
                "id": "5672dbafb85a544148000003",
                "name": "VINOS Reward 5",
                "price": "5",
                "product_id": "72360",
                "quantity": 1,
                "tags": {}
            }
        ],
        "transaction": {
            "amount": "5",
            "created_at": "2015-12-17T15:58:39.862Z",
            "currency": "VINOS",
            "id": "5672dbafb85a544148000001",
            "memo": "vinos credit",
            "status": "complete",
            "type": "vin_credit",
            "updated_at": "2015-12-17T15:58:39.862Z"
        },
        "type": "vin_credit",
        "updated_at": "2015-12-17T15:58:39.859Z",
        "user_id": "563d0b47b85a5435fd000001"
    }
]
```

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

## Data store
In the live environment (see the above topology), the data store for the API is a MongoDB cluster. The configuration for this 
 is a replica set with 3 members. See the Mongo documentation for more information:
 - [3 member architecture](https://docs.mongodb.org/manual/core/replica-set-architecture-three-members/)
 - [replication](https://docs.mongodb.org/v3.0/MongoDB-replication-guide-v3.0.pdf)
 
### Replica set setup on EC2 - step by step

The following steps were used to create the Mongo instances and volumes described in the 'Live environment and topology' table above.

#### 1. Create the instances and volumes

This assumes a working knowledge of Amazon AWS EC2. 

| Step                                             | Command/description                   |
|--------------------------------------------------|---------------------------------------|
| Create 3 identical instances with the following: | t2 small, Ubuntu 14.04 64 bit         |
| Create 3 identical volumes with the following:   | EBS, 50 GB, GP2 (general purpose ssd) |
| Attach volume to each instance                   | Done via the AWS console (volumes)    |

#### 2. Install MongoDB on each instance

| Step                                                      | Linux command/description                                                                                                           | Sample                                                                                                              |
|-----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| Add key server                                            | ```sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10```                                                    |                                                                                                                     |
| Install Mongo                                             | ```echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list``` |                                                                                                                     |
|                                                           | ```sudo apt-get update```                                                                                                           |                                                                                                                     |
|                                                           | ```sudo apt-get install mongodb-10gen```                                                                                            |                                                                                                                     |
| Check volumes attached to instance                        | ```lsblk```                                                                                                                         | ```NAME,MAJ:MIN RM SIZE RO TYPE MOUNTPOINT xvda,202:0,0,8G,0 disk,└─xvda1 202:1,0,8G,0 part / xvdf,202:80,0,50G,0 disk``` |
| Make filesystem on new volume (ensure its the right one!) | ```sudo mkfs -t ext4 /dev/xvdf```                                                                                                   |                                                                                                                     |
| Make directory in root of instance                        | ```sudo mkdir /database```                                                                                                          |                                                                                                                     |
|                                                           | ```echo '/dev/xvdf /database ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab```                                     |                                                                                                                     |
| Mount the new volume to the new directory                 | ```sudo mount /dev/xvdf /database```                                                                                                |                                                                                                                     |
| Cd to the new directory, and create new sub-directories   | ```cd /database/```                                                                                                                 |                                                                                                                     |
|                                                           | ```sudo mkdir data journal log```                                                                                                   |                                                                                                                     |
| Change the owner of the new directory                     | ```sudo chown -R mongodb:mongodb /database```                                                                                       |                                                                                                                     |
| Create a link to the journal                              | ```sudo ln -s /database/journal /database/data/journal```                                                                           |                                                                                                                     |
| Modify the config                                         | ```sudo nano /etc/mongodb.conf```                                                                                                   | ```#mongodb.conf dbpath=/database/data logpath=/database/log/mongodb.log replSet = IGREPSET_1```                          |
| Restart the server                                        | ```sudo service mongodb stop``` ```sudo service mongodb start```                                                                                                                           |                                                                                                                     |

The replica set should now be ready for use.

#### 3. Configure the replica set

| Step                                                                                                                    | Command/description                                                                                                                                                                                | Sample response                                                                                                                                                                                                                                                                                        |
|-------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Open Mongo shell on the primary EC2 instance                                                                            | ```mongo ```                                                                                                                                                                                             |```MongoDB shell version: 2.4.14 connecting to: test >```                                                                                                                                                                                                                                                    |
| Check configuration                                                                                                     | ```> db._adminCommand( {getCmdLineOpts: 1})```                                                                                                                                                           |```{"argv": [ "/usr/bin/mongod", "--config", "/etc/mongodb.conf" ], "parsed":{ "config":"/etc/mongodb.conf", "dbpath":"/database/data", "logappend":"true", "logpath":"/database/log/mongodb.log", "replSet":"IGREPSET_1" }, "ok" : 1 }``` |
| Configure members of replica set (done on PRIMARY). Ensure that the IP addresses and ports are available to connect to. | ```> config = { "_id":"IGREPSET_1", "members":[ {"_id":0, "host":"10.0.1.28:27017"}, {"_id":1, "host":"10.0.1.228:27017"}, {"_id":2, "host":"10.0.1.238:27017"} ] }```                                   |```{ "_id":"IGREPSET_1", "members" [ { "_id":0, "host":"10.0.1.28:27017" }, { "_id":1, "host":"10.0.1.228:27017" }, { "_id":2, "host":"10.0.1.238:27017" } ] }```                                        |
| Connect to database (PRIMARY)                                                                                           | ```> db = (new Mongo("10.0.1.28:27017")).getDB("test")```                                                                                                                                                |```{ "info":"Config now saved locally. Should come online in about a minute.", "ok":1 }```                                                                                                                                                                                                             |
| Confirm (open Mongo shell and check that the prompt shows,the replica set)                                              | ```mongo```                                                                                                                                                                                              |```MongoDB shell version: 2.4.14 connecting to: test IGREPSET_1:PRIMARY>```                                                                                                                                                                                                                                  |

### Data store backups

Currently, snapshots are being taken of a secondary volume. Restoration is described here:

- http://serverfault.com/questions/469847/mongodb-disaster-prep-on-aws
- http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-modifying-snapshot-permissions.html
- http://cloudacademy.com/blog/how-to-manage-ebs-volumes-snapshots-in-aws/

## SSL certificates
All requests to the API are made via HTTPS (SSL). The DNS is set to forward requests to the load balancer, which currently has a wildcard
 SSL certificate installed on it. Requests are then forwarded to the proxy (nginx) over HTTP, which handles the routing to the API in 
 the private subnet.
 
## Resources and links

- ID-IO
    - [Github and API docs](https://github.com/InfinityG/id-io)

- Peach Payments
    - [API docs](https://peachpayments.docs.oppwa.com/)
    - [Test cards](http://support.peachpayments.com/hc/en-us/articles/203019488-Test-Cards-for-Peach-Payments)
    - [Payment return codes](http://support.peachpayments.com/hc/en-us/articles/200694456-Available-Return-Codes-000-000-000-to-999-999-999-)
    - [BIP Platform - test](https://peachpayments.test.ctpe.info/?merchant_name=Peach+Payments)
    - [BIP Platform - live]( https://peachpayments.ctpe.info/Reserve+Wine/)

- WooCommerce
    - [API docs](http://woothemes.github.io/woocommerce-rest-api-docs/)

- Wumdrop
    - [API docs](https://wumdrop.readme.io/docs)