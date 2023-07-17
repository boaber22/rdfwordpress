resource "aws_key_pair" "rdf_web_server_key" {
  key_name   = "rdf_web_server_key"
  public_key = file("./rdf_web_server.pub")
}

data "template_file" "ec2userdata" {
  template = file("./user_data_copy.tpl")
  vars = {
    db_RDS            = aws_db_instance.rdf_rds_instance.address
    db_admin_username = sensitive(var.dbadminun)
    db_admin_password = sensitive(var.dbadminpw)
    db_wp_username    = sensitive(var.dbuserun)
    db_wp_password    = sensitive(var.dbuserpw)
    db_name           = sensitive(var.dbname)
  }

  depends_on = [aws_db_instance.rdf_rds_instance]

}


resource "aws_instance" "rdf_web_server_ec2" {
  ami           = "ami-0a6006bac3b9bb8d3"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.rdf_public_web.id
  key_name      = aws_key_pair.rdf_web_server_key.id
  user_data     = data.template_file.ec2userdata.rendered

  depends_on = [aws_db_instance.rdf_rds_instance, aws_subnet.rdf_public_web]

  tags = {
    Name    = "rdf_ec2_wp_web_server"
    Project = var.ProjectName
  }

}

resource "aws_eip" "rdf_eip" {
  instance = aws_instance.rdf_web_server_ec2.id


  tags = {
    Name    = "rdf_eip"
    Project = var.ProjectName
  }

  depends_on = [aws_instance.rdf_web_server_ec2, aws_internet_gateway.rdf_igw]

}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.rdf_web_server_sg.id
  network_interface_id = aws_instance.rdf_web_server_ec2.primary_network_interface_id

  depends_on = [aws_instance.rdf_web_server_ec2, aws_security_group.rdf_web_server_sg]
}