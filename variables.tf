variable "region" {
  default = "eu-west-2"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "~/.ssh/gh_rsa.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "key-01"
}

variable "amis" {
  type = "map"
  default = {
    "eu-west-2" = "ami-b83023dc"
  }
}
