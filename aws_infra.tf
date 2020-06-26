provider "aws" {
  version = "~> 2.0"
  region  = var.region
}



resource "aws_vpc" "poc_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_internet_gateway" "poc_ig" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_route_table" "poc" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc_ig.id
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "poc_subnet" {
  vpc_id                  = aws_vpc.poc_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.cidr_blocks
  map_public_ip_on_launch = true

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_route_table_association" "poc" {
  route_table_id = aws_route_table.poc.id
  subnet_id      = aws_subnet.poc_subnet.id
}

resource "aws_security_group" "poc_sg" {
  name_prefix = var.namespace
  vpc_id      = aws_vpc.poc_vpc.id


# HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


#HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



