data "aws_iam_policy_document" "ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs-service-policy" {
  name = "test_policy"

  description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
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
          "ecr:GetAuthorizationToken",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role" "ecs-role" {
  name = "ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    },
    {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": ["ecs.amazonaws.com","ec2.amazonaws.com","ecs-tasks.amazonaws.com"]
        }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-policy-attach" {
  role       = "${aws_iam_role.ecs-role.name}"
  policy_arn = "${aws_iam_policy.ecs-service-policy.arn}"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name  = "ecs_instance_profile"
  roles = ["${aws_iam_role.ecs-role.name}"]
}
