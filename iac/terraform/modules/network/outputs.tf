output "vpc_id" {
  description = "ID de la VPC por defecto"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "IDs de las subnets por defecto, dentro de la vpc"
  value       = data.aws_subnets.default.ids
}
