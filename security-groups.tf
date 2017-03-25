resource "aws_security_group" "load-balancer" {
  name        = "load-balancer-security-group"
  description = "Allow all inbound traffic from internet to load balancer"
  vpc_id      = "${aws_vpc.ecs-cluster.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "load-balancer-security-group"
  }
}

resource "aws_security_group" "ecs-host" {
  name        = "ecs-host"
  description = "Only allow inbound traffic from load-balancer"
  vpc_id      = "${aws_vpc.ecs-cluster.id}"

  /*ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load-balancer.id}"]
  }*/

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["31.187.34.108/32"]
  }
  tags {
    Name = "ecs-host-security-group"
  }
}
