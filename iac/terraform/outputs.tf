 // id de la VPC por defecto (desde el módulo network)
output "vpc_id" {
  description = "ID de la VPC por defecto usada en el proyecto"
  value       = module.network.vpc_id
}

// subnets de la VPC por defecto
output "subnet_ids" {
  description = "Lista de subnets de la VPC por defecto"
  value       = module.network.subnet_ids
}
