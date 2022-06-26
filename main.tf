terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.19"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "ec2_ssh_public_key" {}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "public_subnet_main"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main_route_table"
  }
}

resource "aws_route_table_association" "rtb_subnect_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
      name = "state"
      values = ["available"]
  }
  filter {
      name = "name"
      values = ["amzn2-ami-hvm-2.0.*"]
  }
}

resource "aws_instance" "main-ec2" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.main-ec2-key-pair.id

  tags = {
    Name = "main-ec2"
  }
}

resource "aws_key_pair" "main-ec2-key-pair" {
  key_name   = "test_key"
  public_key = file("./.ssh/${var.ec2_ssh_public_key}")
}