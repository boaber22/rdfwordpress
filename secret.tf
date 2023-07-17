#Create 2 new secrets in AWS secrets manager for the root databsae and primary wordpress user credentials
resource "aws_secretsmanager_secret" "DB_admin_creds" {
  name        = "RDF_WordPress_RDS_DBadmin"
  description = "Admin credentials for RDF RDS MySQL Wordpress DB"

  tags = {
    Project = var.ProjectName
  }
}

resource "aws_secretsmanager_secret_version" "DB_admin_creds_ver" {
  secret_id     = aws_secretsmanager_secret.DB_admin_creds.id
  secret_string = jsonencode(var.RdsAdminCreds)
}

resource "aws_secretsmanager_secret" "DB_user_creds" {
  name        = "RDF_WordPress_RDS_DBuser"
  description = "Main user for RDF RDS Wordpress DB mySQL instance"

  tags = {
    Project = var.ProjectName
  }
}

resource "aws_secretsmanager_secret_version" "DB_user_creds_ver" {
  secret_id     = aws_secretsmanager_secret.DB_user_creds.id
  secret_string = jsonencode(var.RdsUserCreds)
}




