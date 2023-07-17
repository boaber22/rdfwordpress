resource "aws_db_subnet_group" "rdf_db_subnet_grp" {
  name        = "rdf rds subnet group"
  description = "RDF Wordpress RDS DB subnet group"
  subnet_ids  = [aws_subnet.rdf_private_sn_1.id, aws_subnet.rdf_private_sn_2.id]

  tags = {
    Project = var.ProjectName
  }
}


resource "aws_db_instance" "rdf_rds_instance" {
  allocated_storage      = 20
  identifier             = sensitive(var.dbname)
  db_name                = sensitive(var.dbname)
  engine                 = "mysql"
  engine_version         = "8.0.32"
  instance_class         = "db.t3.micro"
  username               = sensitive(var.dbadminun)
  password               = sensitive(var.dbadminpw)
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rdf_db_subnet_grp.id
  vpc_security_group_ids = [aws_security_group.rdf_rds_sg.id]

  tags = {
    Name    = "rdf_rds_instance"
    Project = var.ProjectName
  }

  # make sure rds manual password chnages is ignored
  lifecycle {
    ignore_changes = [password]
  }
}