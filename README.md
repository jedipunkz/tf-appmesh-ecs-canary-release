# tf-appmesh-ecs-canary-release

Terraform Code for Canary Release Deployment with AWS App Mesh &amp; ECS

## Pre-Requirement

- terraform 1.0 or later

## Deploy App Mesh & ECS Env with Terraform

```shell
$ cd tf-appmesh-ecs-canary-release
$ terraform plan
$ terraform apply
```

## access NLB to see container's response

```shell
$ curl http://<NLB_DNS_NAME>/
example1 or example2 (95:5 ratio)
```

### 

## License

MIT

