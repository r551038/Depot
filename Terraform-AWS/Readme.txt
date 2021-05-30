Terraform template demonstrates the ability to use the same template without modification
to deploy to various environments.
This is accomplished by the use of terraform workspaces to configure assets parameter.

Template deploys the following assets:
A VPC, Subnet, route table, internet gateway, security group,elastic IP and a linux VM with apache installed.

Deployments made using workspaces will vary in the parameters noted below.
All other resources will be have the same parameters across all workspaces.

workspace prod
aws_vpc.mainvpc = 10.0.0.0/16,"Name" = "vpc-terrafm-prod"
aws_subnet.web-subnet = 10.0.1.0/24,"Name" = "web-subnet-prod"
aws_internet_gateway.terraigw = terraaigw-prod
aws_eip.WebServNicIP = 10.0.1.40

workspace dev
aws_vpc.mainvpc: = 192.168.0.0/16,"Name" = "vpc-terrafm-dev"
aws_subnet.web-subnet = 192.168.1.0/24,Name" = "web-subnet-dev"
aws_internet_gateway.terraigw = terraaigw-dev
aws_eip.WebServNicIP = 192.168.1.40



