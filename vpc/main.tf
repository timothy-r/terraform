
# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a public subnet to launch our instances into
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "public"
  }
}

# Create a private subnet to launch our instances into
resource "aws_subnet" "private_01" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"

  tags {
    Name = "private 01"
  }
}

# Create a second private subnet to launch our instances into
resource "aws_subnet" "private_02" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"

  tags {
    Name = "private 02"
  }
}


resource "aws_security_group" "vm" {
  name        = "default_sg_01"
  description = "Default security group, for SSH & HTTP"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "vm" {

  connection {
    user = "ubuntu"
  }

  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.auth.id}"

  tags {
    Name = "Ubuntu vm"
  }

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.vm.id}"]

  # Launch into the public subnet as with ELB
  subnet_id = "${aws_subnet.public.id}"

}
