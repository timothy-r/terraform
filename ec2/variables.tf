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

}

variable "key_name" {
  description = "Name of the AWS key pair"
  default = "key-01"
}

variable "amis" {
  type = "map"
  default = {
    "eu-west-2" = "ami-b83023dc"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "hostname" {
  description = <<DESCRIPTION
Enter the hostname to create the sub-domain under.
Don't forget to add a trailing dot!

Example: my-fab-host.com.
DESCRIPTION

}

variable "sub_domain" {
  description = "Enter the sub domain for this instance"
}

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "instance_count" {
  description = "Number of web vms to run"
  default = 3
}