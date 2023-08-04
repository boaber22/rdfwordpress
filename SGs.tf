# Create a security group to allow SSH, http and https traffic to the ec2 web server
resource "aws_security_group" "rdf_web_server_sg" {
  name        = "rdf_web_server_SG"
  description = "Allow ssh and http"
  vpc_id      = aws_vpc.rdf_vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]
  }

  ingress {
    description = "http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https from anywhere"
    from_port   = 443
    to_port     = 443
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
    Name    = "rdf_web_server_sg"
    Project = var.ProjectName
  }
}

# Create a security group for the RDS database that only accepts incoming requests from the ec2 security group
resource "aws_security_group" "rdf_rds_sg" {
  name   = "RDF_RDS_SG"
  vpc_id = aws_vpc.rdf_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.rdf_web_server_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "rdf_rds_sg"
    Project = var.ProjectName
  }
}