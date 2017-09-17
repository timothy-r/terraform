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
  default = "key-vpc-demo"
}

variable "amis" {
  type = "map"
  default = {
    "eu-west-2" = "ami-996372fd"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}