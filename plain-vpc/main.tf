
# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "default"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "InternetGW"
  }
}

resource "aws_route_table" "dmz" {

  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "DMZ"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_route_table.dmz.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"

}

# associate dmz subnet with the dmz route table
resource "aws_route_table_association" "dmz" {
  subnet_id      = "${aws_subnet.dmz.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}


# Create a public subnet to launch our instances into
resource "aws_subnet" "dmz" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet_cidr["DMZ"]}"
  availability_zone       = "${var.subnet_az["DMZ"]}"

  map_public_ip_on_launch = true

  tags = {
    Name = "DMZ"
  }
}



resource "aws_security_group" "vm" {
  name        = "${var.sg_name}"
  description = "VM security group, for SSH & HTTP"
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
