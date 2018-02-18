variable "region" {
  default = "eu-west-2"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION

}

variable "key_name" {
  description = "Name of the AWS key pair"
  default = "key-vpc-ace"
}

variable "amis" {
  type = "map"
  default = {
    "eu-west-2" = "ami-996372fd"
    "us-east-1" = "ami-cd0f5cb6"
  }
}

variable "instance_type" {
  default = "t2.micro"
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