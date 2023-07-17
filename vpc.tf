resource "aws_vpc" "rdf_vpc" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name    = "rdf_vpc"
    Project = var.ProjectName
  }
}


resource "aws_internet_gateway" "rdf_igw" {
  vpc_id = aws_vpc.rdf_vpc.id

  tags = {
    Name    = "rdf_igw"
    Project = var.ProjectName
  }
}

resource "aws_subnet" "rdf_public_web" {
  vpc_id                  = aws_vpc.rdf_vpc.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "rdf_public_subnet"
    Project = var.ProjectName
  }
}

resource "aws_subnet" "rdf_private_sn_1" {
  vpc_id            = aws_vpc.rdf_vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name    = "rdf_private_subnet_1"
    Project = var.ProjectName
  }
}

resource "aws_subnet" "rdf_private_sn_2" {
  vpc_id            = aws_vpc.rdf_vpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name    = "rdf_private_subnet_2"
    Project = var.ProjectName
  }
}

resource "aws_route_table" "rdf_rt" {
  vpc_id = aws_vpc.rdf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rdf_igw.id
  }

  tags = {
    Name    = "rdf_rt"
    Project = var.ProjectName
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id      = aws_subnet.rdf_public_web.id
  route_table_id = aws_route_table.rdf_rt.id
}

