resource "aws_ecs_cluster" "demo-ecs-cluster" {
  name = "demo-ecs-cluster"
}

resource "aws_launch_configuration" "ecs-asg-launch-conf" {
  name                 = "ecs-asg-launch-conf"
  image_id             = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type        = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  security_groups      = ["${aws_security_group.ecs-host-sg.id}"]
  key_name             = "${aws_key_pair.ec2_key.key_name}"

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.demo-ecs-cluster.name} >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "ecs-asg" {
  name = "ecs-asg"

  max_size         = 5
  min_size         = 2
  desired_capacity = 3

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier  = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.ecs-asg-launch-conf.name}"

  tag {
    key                 = "Name"
    value               = "ecs-host"
    propagate_at_launch = true
  }
}
