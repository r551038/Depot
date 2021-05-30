provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""

}


resource "aws_vpc" "mainvpc" {

  cidr_block = lookup(var.cidr_blockselc, terraform.workspace)

  instance_tenancy = "default"

  tags = {
    Name = "vpc-terrafm-${terraform.workspace}"

  }
}


resource "aws_internet_gateway" "terraigw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "terraaigw-${terraform.workspace}"
  }
}


resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraigw.id
  }

  tags = {
    Name = "mainTable-${terraform.workspace}"

  }
}


resource "aws_subnet" "web-subnet" {
  vpc_id = aws_vpc.mainvpc.id
  cidr_block        = lookup(var.cidr_subselc, terraform.workspace)
  availability_zone = "us-east-1a"

  tags = {
    Name = "web-subnet-${terraform.workspace}"
  }
}


resource "aws_route_table_association" "terrartble" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}


resource "aws_security_group" "WebServerAccess" {
  name        = "Allow web and admin access"
  description = "Allow server inbound traffic"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    description = "TLS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }




  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_Web_server_access"
  }
}

resource "aws_network_interface" "WebServNic" {
  subnet_id = aws_subnet.web-subnet.id

  private_ips = [lookup(var.priv_ipenvselc, terraform.workspace)]

  security_groups = [aws_security_group.WebServerAccess.id]

}


resource "aws_eip" "WebServNicIP" {
  vpc                       = true
  network_interface         = aws_network_interface.WebServNic.id
  associate_with_private_ip = lookup(var.priv_ipenvselc, terraform.workspace)
  depends_on = [
    aws_internet_gateway.terraigw
  ]
}


resource "aws_instance" "Web-ServerVM" {
  ami               = "ami-042e8287309f5df03"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "Yourkey"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.WebServNic.id
  }

  user_data = <<-EOF
           #!/bin/bash
           sudo apt install apache2 -y
           sudo apt update -y
           sudo bash -c 'echo welcome to Apac webtest > /var/www/html/index.html'
           sudo systemctl start apache2
           EOF

  tags = {
    "Name" = "WebServer1-${terraform.workspace}"
  }
}
