resource "aws_alb" "ecs-services-alb" {
  name            = "ecs-services-alb"
  internal        = false
  security_groups = ["${aws_security_group.load-balancer.id}"]
  subnets         = ["${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}"]

  enable_deletion_protection = false

  tags {
    Name = "ecs-services-alb"
  }
}

resource "aws_alb_target_group" "default-target-group" {
  name     = "default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.ecs-cluster.id}"
}

resource "aws_alb_listener" "default-target-group" {
  load_balancer_arn = "${aws_alb.ecs-services-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default-target-group.arn}"
    type             = "forward"
  }
}
