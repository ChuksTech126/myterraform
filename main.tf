provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "demotf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demotf_vpc"
  }
}

resource "aws_internet_gateway" "demotf_igw" {
  vpc_id = aws_vpc.demotf_vpc.id
}

resource "aws_subnet" "demotf_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.demotf_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "demotf_subnet_1"
  }
}

resource "aws_subnet" "demotf_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.demotf_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "demotf_subnet_2"
  } 
}

resource "aws_subnet" "demotf_subnet_3" {
  cidr_block = "10.0.3.0/24"
  vpc_id     = aws_vpc.demotf_vpc.id
  availability_zone = "us-east-1c"
  tags = {
    Name = "demotf_subnet_3"
  }
}

resource "aws_route_table" "demotf_route_table" {
  vpc_id = aws_vpc.demotf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demotf_igw.id
  }
}

resource "aws_route_table_association" "demotf_route_table_association_1" {
  subnet_id      = aws_subnet.demotf_subnet_1.id
  route_table_id = aws_route_table.demotf_route_table.id
}

resource "aws_route_table_association" "demotf_route_table_association_2" {
  subnet_id      = aws_subnet.demotf_subnet_2.id
  route_table_id = aws_route_table.demotf_route_table.id
}

resource "aws_route_table_association" "demotf_route_table_association_3" {
  subnet_id      = aws_subnet.demotf_subnet_3.id
  route_table_id = aws_route_table.demotf_route_table.id
}

resource "aws_security_group" "demotf_security_group" {
  name_prefix = "demo_sg_"
  vpc_id      = aws_vpc.demotf_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "instance_keypair" {
  description = "AWS EC2 key pair for ssh access"
  type = string
  default ="demo-kp"
  sensitive = true
}

resource "aws_instance" "demotf_instance" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.demotf_subnet_1.id
  key_name = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.demotf_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "demotf-instance"
  }
}