resource "aws_appmesh_mesh" "example" {
  name = "example"
}

resource "aws_appmesh_virtual_gateway" "example" {
  name      = "example"
  mesh_name = aws_appmesh_mesh.example.name

  spec {
    listener {
      port_mapping {
        port     = 9080
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_gateway_route" "example" {
  name                 = "example"
  mesh_name            = aws_appmesh_mesh.example.name
  virtual_gateway_name = aws_appmesh_virtual_gateway.example.name

  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = aws_appmesh_virtual_service.example.name
          }
        }
      }

      match {
        prefix = "/"
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "example" {
  name      = "exmaple"
  mesh_name = aws_appmesh_mesh.example.id

  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.example.name
      }
    }
  }
}

resource "aws_appmesh_virtual_router" "example" {
  name      = "example"
  mesh_name = aws_appmesh_mesh.example.id

  spec {
    listener {
      port_mapping {
        port     = 80
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_route" "example" {
  name                = "example"
  mesh_name           = aws_appmesh_mesh.example.id
  virtual_router_name = aws_appmesh_virtual_router.example.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.example1.name
          weight       = 95
        }

        weighted_target {
          virtual_node = aws_appmesh_virtual_node.example2.name
          weight       = 5
        }
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "example1" {
  name      = "example1"
  mesh_name = aws_appmesh_mesh.example.id

  spec {
    listener {
      port_mapping {
        port     = 80
        protocol = "http"
      }
      health_check {
        protocol            = "http"
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = aws_service_discovery_private_dns_namespace.example.name
        service_name   = "example1"
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "example2" {
  name      = "example2"
  mesh_name = aws_appmesh_mesh.example.id

  spec {
    listener {
      port_mapping {
        port     = 80
        protocol = "http"
      }
      health_check {
        protocol            = "http"
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = aws_service_discovery_private_dns_namespace.example.name
        service_name   = "example2"
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }
}

