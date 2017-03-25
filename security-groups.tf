resource "aws_security_group" "bastion-host-sg" {
  name        = "bastion-host-sg"
  description = "Only allow SSH from trusted IPs"
  vpc_id      = "${aws_vpc.ecs-cluster.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["31.187.34.108/32"]
  }

  egress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["10.240.0.0/16"]
  }

  tags {
    Name = "bastion-host-security-group"
  }
}

resource "aws_security_group" "ecs-lb-sg" {
  name        = "ecs-lb-sg"
  description = "All internet traffic will be accepted by lb"
  vpc_id      = "${aws_vpc.ecs-cluster.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-lb-security-group"
  }
}

resource "aws_security_group" "ecs-host-sg" {
  name        = "ecs-host-sg"
  description = "Only allow inbound traffic from load-balancer"
  vpc_id      = "${aws_vpc.ecs-cluster.id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.ecs-lb-sg.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-host-sg.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-host-security-group"
  }
}
