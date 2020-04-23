AWS Transit Gateway w/MongoDB Atlas Peering using Hashicorp Terraform
===========================================

This example of MongoDB Peering, uses the AWS Transit gateway, as a simple way to move between environments.  

SSH Forwarding
--------------

To simpliy access, the easiest way to move between VPC is to use SSH Forwarding.

# Host Environment
Start the agent
```sh
ssh-agent
```

Add you PEM encoded key
```sh
ssh-add ~/.ssh/id_rsa
```

Enbable SSH Forwarding
```sh
ssh -A ubuntu@<instance public IPv4>
```

All you need to know is where you want to go
## Between VPCs
```sh
ssh 10.13.1.10
```

Architecture
------------

A Transit Gateway relies on Route Tables. By default, a new Route Table is created in the Transit Gateway, which populates with the routing info toward every VPC attached to the gateway (the full mesh scenario)
The Terraform code in this project demonstrates a more complex scenario in which traffic is isolated based on the environment. Four VPCs are created, with two subnets each (in separate AZs):
* VPC-1: in the 'dev' environment
* VPC-2: in the 'dev' environment
* VPC-3: in the 'shared' environment
* VPC-4: in the 'prod' environment

There is a 'shared' environment will host shared enterprise components, such as proxy services, tools

## Access rules for the Transit Gateway are:
* The shared VPC can access dev and prod VPCs.
* The dev VPCs can access each other, and the shared VPC
* The prod VPCs can only access the shared VPC

To enable this use case, three Route Tables are created in the Transit Gateway, one per environment.  Both dev VPCs attach to the same Route Table, whereas the shared and prod VPCs each attach to their respective Route Table. 

Each VPC gets a t2.micro Ubuntu instance to validate the network connectivity over ssh and ICMP (ping). The instance in the 'shared' is assigned a public IP so a VPN connection isn't needed. 

The production environment has a Centos AMI, with MongoDB Binaries pre-installed. Both US-WEST-1 and US-WEST-2 Mongo Centos AMIs are documented in the variables.tf

## Architecture Implementation

![transit-gateway-architecture](./image/transit-gateway-demo.png?raw=true "Transit Gateway Architecture")

The green links on the diagram represents the authorized traffic flows through the gateway.

Prerequisites
-------------

Be sure to set up your AWS Credentials.  They are read by Terraform

```sh
[default]
aws_access_key_id = Foo1
aws_secret_access_key = Bar1
region = us-west-2

[personal]
aws_access_key_id=Foo2
aws_secret_access_key=Bar2
region = us-west-2
```

I set the following environment variables in my ~/.bash_profile
```sh
AWS_PROFILE=default
AWS_DEFAULT_REGION=us-west-1
```
Note: I am overridding the us-west-2 in my credentials file with the value of AWS_DEFAULT_REGION.  Terraform takes this value.

#Usage
#-----
* Change the public_key value to a keypair you own
* Deploy the setup with:
```sh
$ terraform init
$ terraform plan
$ terraform apply
```
* The public IP of the instance in the 'shared' VPC is printed when deployment ends
* ssh on this instance
```sh
$ ssh -i your_private_key ubuntu@$PUBLIC_IP
```
* Check you can ping and ssh any other instance in the other VPCs
* Also check that, from a dev instance (1 & 2) you cannot reach the prod instance (4) and vice-versa.
* You can now access the MongoDB Atlas Cluster, either via the Transit gateway through VPC 3 (that you 
* log into or by ssh to VPC 4 and accessing the Mongo Cluster that way as well.
*
* There is no need to Whitelist the Private Link CIDR, as you need to for VPC Peering.  The RFC 1918 private
* IPs can be accessed from your cluster.  See connecting in the screenshot below:
*
* ![mongodb-connect](./image/connect.jpg?raw=true "Private Link Connection")
*
*
* Delete all resources
```sh
$ terraform destroy
```
