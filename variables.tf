variable "ProjectName" {
  type    = string
  default = "Robert Does Fishing"
}

variable "RdsAdminCreds" {
  type      = map(string)
  sensitive = true
}

variable "RdsUserCreds" {
  type      = map(string)
  sensitive = true
}

variable "dbname" {
  type = string
}

variable "dbadminun" {
  type = string
}

variable "dbadminpw" {
  type = string
}

variable "dbuserun" {
  type = string
}

variable "dbuserpw" {
  type = string
}