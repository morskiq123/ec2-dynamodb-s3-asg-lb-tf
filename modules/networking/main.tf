# Required information for to make TF work 
# with AWS

terraform{
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider aws{
    region = "eu-central-1"
}

##################################
############### VPC ##############
##################################

resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "app_vpc"
  }
}

##################################
######## PUBLIC SUBNETS ##########
##################################

# Creates 2 public subnets in the VPC
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_list)

  vpc_id = var.id_vpc
  cidr_block = var.public_subnets_list[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.app_name}_public_subnets"
  }
}

# Creates an Internet Gateway in the VPC for Internet connection
resource "aws_internet_gateway" "igw" {
  vpc_id = var.id_vpc
  tags = {
    Name = "${var.app_name}_igw"
  }
}

# Route table used for routing the traffic from the 
# public subnet to the Internet Gateway
resource "aws_route_table" "public_routetable" {
  vpc_id = var.id_vpc

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.app_name}_public_routetable"
  }
}

# Associate the route table with the Internet Gateway, making 
# the subnets public
resource "aws_route_table_association" "public_associations" {
  count = length(var.public_subnets_list)

  subnet_id = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_routetable.id
}

