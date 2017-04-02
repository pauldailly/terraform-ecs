resource "aws_ecs_task_definition" "nginx-task" {
  family                = "nginx"
  container_definitions = "${file("container-definitions/nginx.json")}"
}

resource "aws_ecs_service" "nginx-service" {
  name            = "nginx-service"
  cluster         = "${aws_ecs_cluster.demo-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx-task.arn}"
  desired_count   = 3

  iam_role   = "${aws_iam_role.ecs-role.arn}"
  depends_on = ["aws_iam_role.ecs-role", "aws_iam_policy.ecs-service-policy", "aws_alb.ecs-cluster-lb"]

  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-nginx-lb-target-group.arn}"
    container_name   = "nginx-container2"
    container_port   = 80
  }
}
