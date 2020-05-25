variable "region" {
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "subnet_cidr" {
  type = "map"
  default = {
    "DMZ" = "192.168.1.0/24"
    "DB"  = "192.168.2.0/24"
    "APP" = "192.168.3.0/24"
  }
}

variable "subnet_az" {
  type = "map"
  default = {
    "DMZ" = "eu-west-2a"
    "DB"  = "eu-west-2c"
    "APP" = "eu-west-2b"
  }
}

variable "sg_name" {
  default = "sg-one"
}
