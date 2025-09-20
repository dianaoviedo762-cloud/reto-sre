// Obtiene la VPC por defecto de AWS
data "aws_vpc" "default" {
  default = true
}

// Obtiene las subnets de la VPC por defecto
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
