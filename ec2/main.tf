
# Create a VPC to launch our instances into
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name = "${var.system_name} VPC"
    System = "${var.system_name}"
  }
}

# Create an internet gateway for public subnet access
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.system_name} IGW"
    System = "${var.system_name}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create public subnets to launch the instances into
resource "aws_subnet" "public" {
  count = 2

  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.public_subnet_cidrs, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  map_public_ip_on_launch = true

  tags {
    Name = "public-${count.index}"
    System = "${var.system_name}"
  }
}

resource "aws_security_group" "elb" {

  description = "A security group for the ELB, accessible via the web"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name = "lb 01"
    System = "${var.system_name}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {

  description = "Default security group, for SSH & HTTP"
  vpc_id      = "${aws_vpc.main.id}"

  tags {
    Name = "web 01"
    System = "${var.system_name}"
  }

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

resource "aws_elb" "web" {

  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  # add all the vms to the elb
  instances       = ["${aws_instance.web.*.id}"]

  tags {
    Name = "LB web 01"
    System = "${var.system_name}"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.hostname}"
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.sub_domain}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.web.dns_name}"
    zone_id                = "${aws_elb.web.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.system_name}-${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {

  count = "${var.instance_count}"

  connection {
    user = "${var.user_name}"
  }

  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.auth.id}"

  # place the vms inside multiple azs
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name = "web-${count.index}"
    System = "${var.system_name}"
  }

  # Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  # Launch into the public subnet as with ELB
  subnet_id =  "${element(aws_subnet.public.*.id, count.index)}"

  # install nginx and start it
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
