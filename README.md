# Overview

## Infrastructure
Having run `terraform apply` the following infrastructure items will be created within AWS:

### Users and access
1. An IAM user called 'ecsadmin'
2. An IAM user group called 'ecsadmins' with administrator access policy
3. Create an SSH key pair called 'ecsadmin'

### Networking
1. A VPC called ecs_vpc with /16 network
2. Subnet
3. Security group - inbound SSH, inbound HTTPS 443 and inbound HTTP 80

### ECS cluster
1. Give cluster ec2 instance role so that it can create instances
2. Define services
3. Define tasks
4. Autoscaling group

## TODO

1. Add the following config to 
