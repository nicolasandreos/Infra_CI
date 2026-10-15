variable "nome_repositorio" {
  type = string
}

variable "cargoIAM" {
  type = string
}

variable "ambiante" {
  type = string
}

variable "imagem" {
  type = string
}

locals {
  db_username = "postgres"
  db_password = "rootroot"
  db_name     = "root"
  app_port    = 8083
}
