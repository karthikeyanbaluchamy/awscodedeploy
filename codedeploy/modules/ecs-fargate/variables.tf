variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  default = "256"
}

variable "memory" {
  default = "512"
}

variable "desired_count" {
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}