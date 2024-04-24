variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpcCidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t2.micro"
  type = string
}