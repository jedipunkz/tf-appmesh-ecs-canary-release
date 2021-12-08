resource "aws_ecs_cluster" "example" {
  name = "example"
}

resource "aws_ecs_task_definition" "examplegw" {
  family                   = "examplegw"
  cpu                      = "4096"
  memory                   = "8192"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = module.ecs_task_role.iam_role_arn
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  container_definitions    = data.template_file.container_definition_examplegw.rendered
}

resource "aws_ecs_service" "examplegw" {
  name                              = "examplegw"
  cluster                           = aws_ecs_cluster.example.arn
  task_definition                   = aws_ecs_task_definition.examplegw.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.nginx.id]

    subnets = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.examplegw.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "envoy"
    container_port   = 9080
  }
}

data "template_file" "container_definition_examplegw" {
  template = file("./container_definitions/examplegw.tpl")
  vars = {
    appmesh_virtual_node_name = "mesh/${aws_appmesh_mesh.example.name}/virtualGateway/${aws_appmesh_virtual_gateway.example.name}"
  }
}

resource "aws_ecs_task_definition" "example1" {
  family                   = "example1"
  cpu                      = "4096"
  memory                   = "8192"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = module.ecs_task_role.iam_role_arn
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  container_definitions    = data.template_file.container_definition_example1.rendered

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = 80
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "example1" {
  name             = "example1"
  cluster          = aws_ecs_cluster.example.arn
  task_definition  = aws_ecs_task_definition.example1.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.nginx.id]

    subnets = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.example1.arn
  }
}

data "template_file" "container_definition_example1" {
  template = file("./container_definitions/example.tpl")
  vars = {
    nginx_image               = "public.ecr.aws/c1s7y1i8/nginx:example1"
    appmesh_virtual_node_name = "mesh/${aws_appmesh_mesh.example.name}/virtualNode/${aws_appmesh_virtual_node.example1.name}"
  }
}

resource "aws_ecs_task_definition" "example2" {
  family                   = "example2"
  cpu                      = "4096"
  memory                   = "8192"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = module.ecs_task_role.iam_role_arn
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  container_definitions    = data.template_file.container_definition_example2.rendered

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = 80
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "example2" {
  name             = "example2"
  cluster          = aws_ecs_cluster.example.arn
  task_definition  = aws_ecs_task_definition.example2.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.nginx.id]

    subnets = module.vpc.private_subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.example2.arn
  }
}

data "template_file" "container_definition_example2" {
  template = file("./container_definitions/example.tpl")
  vars = {
    nginx_image               = "public.ecr.aws/c1s7y1i8/nginx:example2"
    appmesh_virtual_node_name = "mesh/${aws_appmesh_mesh.example.name}/virtualNode/${aws_appmesh_virtual_node.example2.name}"
  }
}

resource "aws_security_group" "nginx" {
  name        = "examplenginx-sg"
  description = "nginx security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
