# 変数の設定
variable "aws_access_key" {}
variable "aws_secret_key" {}

# Terraform のバージョン指定
terraform {
  required_version = "= 1.4.6"
}

# 変数を利用した provider の設定
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = "ap-northeast-1"
}

# 1 VPC
resource "aws_vpc" "sample-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sample-vpc"
  }
}

# 2 subnet
resource "aws_subnet" "sample-subnet-public01" {
  vpc_id     = aws_vpc.sample-vpc.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "sample-subnet-public01"
  }
}
resource "aws_subnet" "sample-subnet-public02" {
  vpc_id     = aws_vpc.sample-vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "sample-subnet-public02"
  }
}
resource "aws_subnet" "sample-subnet-private01" {
  vpc_id     = aws_vpc.sample-vpc.id
  cidr_block = "10.0.64.0/20"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "sample-subnet-private01"
  }
}
resource "aws_subnet" "sample-subnet-private02" {
  vpc_id     = aws_vpc.sample-vpc.id
  cidr_block = "10.0.80.0/20"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "sample-subnet-private02"
  }
}

# 3 internet-gateway
resource "aws_internet_gateway" "sample-igw" {
  vpc_id = aws_vpc.sample-vpc.id

  tags = {
    Name = "sample-igw"
  }
}

# 4 nat-gateway
resource "aws_nat_gateway" "sample-ngw-01" {
  allocation_id = aws_eip.ngw-eip01.id
  subnet_id = aws_subnet.sample-subnet-public01.id     

  tags = {
    Name = "sample-ngw-01"
  }
  depends_on = [aws_internet_gateway.sample-igw]
}

resource "aws_eip" "ngw-eip01" {
  domain   = "vpc"
  tags = {
    Name = "ngw-eip01"
  }
}

resource "aws_nat_gateway" "sample-ngw-02" {
  allocation_id = aws_eip.ngw-eip02.id
  subnet_id = aws_subnet.sample-subnet-public02.id     

  tags = {
    Name = "sample-ngw-02"
  }
  depends_on = [aws_internet_gateway.sample-igw]
}

resource "aws_eip" "ngw-eip02" {
  domain   = "vpc"
  tags = {
    Name = "ngw-eip02"
  }
}
# 5 route table
resource "aws_route_table" "sample-rt-public" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample-igw.id
  }

  tags = {
    Name = "sample-rt-public"
  }
}
resource "aws_route_table_association" "rt-public-association01" {
  subnet_id      = aws_subnet.sample-subnet-public01.id
  route_table_id = aws_route_table.sample-rt-public.id
}
resource "aws_route_table_association" "rt-public-association02" {
  subnet_id      = aws_subnet.sample-subnet-public02.id
  route_table_id = aws_route_table.sample-rt-public.id
}

resource "aws_route_table" "sample-rt-private01" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample-ngw-01.id
  }

  tags = {
    Name = "sample-rt-private01"
  }
}

resource "aws_route_table_association" "rt-private-association01" {
  subnet_id      = aws_subnet.sample-subnet-private01.id
  route_table_id = aws_route_table.sample-rt-private01.id
}

resource "aws_route_table" "sample-rt-private02" {
  vpc_id = aws_vpc.sample-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample-ngw-02.id
  }

  tags = {
    Name = "sample-rt-private02"
  }
}

resource "aws_route_table_association" "rt-private-association02" {
  subnet_id      = aws_subnet.sample-subnet-private02.id
  route_table_id = aws_route_table.sample-rt-private02.id
}

# 6 security-group
resource "aws_security_group" "sample-sg-bastion" {
  name        = "sample-sg-bastion"
  description = "for bastion server"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample-sg-bastion"
  }
}

resource "aws_security_group" "sample-sg-elb" {
  name        = "sample-sg-elb"
  description = "for load balancer"
  vpc_id      = aws_vpc.sample-vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample-sg-elb"
  }
}

