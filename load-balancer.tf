resource "aws_alb_target_group" "ecs-cluster-lb-target-group" {
  name     = "ecs-cluster-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.ecs-cluster.id}"
}

resource "aws_alb" "ecs-cluster-lb" {
  name            = "ecs-cluster-lb"
  internal        = false
  security_groups = ["${aws_security_group.ecs-lb-sg.id}"]
  subnets         = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]

  enable_deletion_protection = true
}

resource "aws_alb_listener" "ecs-cluster-lb-listener" {
  load_balancer_arn = "${aws_alb.ecs-cluster-lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-cluster-lb-target-group.arn}"
    type             = "forward"
  }
}
