variable "imagem" {
  type        = string
  description = "Imagem Docker no formato usuario/repositorio:tag"
}

module "homolog" {
  source = "../../infra"

  nome_repositorio = "homolog"
  cargoIAM         = "homolog"
  ambiante         = "homolog"
  imagem           = var.imagem
}

output "IP_alb" {
  value = module.homolog.IP
}
