variable "aws_region" {
  description = "Región de AWS donde quedaran o se desplegarán los recursos"
  type        = string
  default     = "us-west-2"
}

/*variable "aws_profile" {
  description = "Perfil de awsCli que usará Terraform"
  type        = string
  default     = "default"
  sensitive = true
}*/ //Ya que estoy usando por el momento el default, esto no es necesario
