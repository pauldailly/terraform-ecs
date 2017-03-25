resource "aws_key_pair" "ecs-cluster-key-pair" {
  key_name   = "ecs-cluster"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "demo-cluster"
}

resource "aws_iam_role" "ecs-role" {
  name = "ecs-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }]
}
EOF
}

resource "aws_iam_role_policy" "ecs-policy" {
  name = "ecs-policy"
  role = "${aws_iam_role.ecs-role.id}"

  policy = <<EOF
{
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "ecs:CreateCluster",
            "ecs:DeregisterContainerInstance",
            "ecs:DiscoverPollEndpoint",
            "ecs:Poll",
            "ecs:RegisterContainerInstance",
            "ecs:StartTelemetrySession",
            "ecs:Submit*",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken"
        ],
        "Resource": "*"
    }]
}
EOF
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name  = "ecs-instance-profile"
  roles = ["${aws_iam_role.ecs-role.name}"]
}

resource "aws_launch_configuration" "ecs-cluster-member-launch-config" {
  name                        = "ecs-cluster-member-launch-config"
  image_id                    = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type               = "${var.INSTANCE_TYPE}"
  security_groups             = ["${aws_security_group.ecs-host.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.name} > /etc/ecs/ecs.config"
  key_name                    = "${aws_key_pair.ecs-cluster-key-pair.key_name}"
  associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "esc-cluster-autoscaling-group" {
  vpc_zone_identifier       = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}"]
  name                      = "esc-cluster-autoscaling-group"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.ecs-cluster-member-launch-config.name}"

  tag {
    key                 = "Name"
    value               = "ECS host"
    propagate_at_launch = true
  }
}

resource "aws_instance" "random_instance" {
  ami = "ami-98ecb7fe"

  instance_type = "t2.micro"

  key_name = "${aws_key_pair.ecs-cluster-key-pair.key_name}"

  associate_public_ip_address = "true"

  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.name}"

  vpc_security_group_ids = ["${aws_security_group.kubernetes-securitygroup.id}"]

  subnet_id = "${aws_subnet.private-subnet-1.id}"

  source_dest_check = "false"

  tags {
    Name = "random instance"
  }
}

resource "aws_security_group" "kubernetes-securitygroup" {
  vpc_id      = "${aws_vpc.ecs-cluster.id}"
  name        = "kubernetes-securitygroup"
  description = "security group that allows ssh and all egress traffic"

  tags {
    Name = "kubernetes-securitygroup"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kubernetes-securitygroup.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
