########### aws details #########################

variable "tags" {
  type    = "map"
  default = {}
}

variable "aws_region" {
  type    = string
}

variable "aws_profile" {
  type    = string
}

variable "aws_creds_file" {
  type    = string
}

variable "key_name" {
  type    = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "vpc_azs" {
  type    = list
  default = ["eu-west-2a","eu-west-2b"]
}

variable "guacamole_image_name" {
  type    = string
}

variable "guacamole_image_owner" {
  type    = string
}

variable "guacamole_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "guacamole_root_disk_size" {
  default = 40
}

variable "guacamole_count" {
  default = 1
}

variable "guacamole_ingress_rules" {
  type    = list(string)
  default = ["ssh-tcp", "https-443-tcp", "http-80-tcp", "http-8080-tcp"]
}

variable "linux_image_name" {
  type    = string
}

variable "linux_image_owner" {
  type    = string
}

variable "linux_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "linux_root_disk_size" {
  default = 40
}

variable "linux_count" {
  default = 1
}

variable "linux_ingress_rules" {
  type    = list(string)
  default = ["ssh-tcp"]
}

variable "windows_image_name" {
  type    = string
}

variable "windows_image_owner" {
  type    = string
}

variable "windows_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "windows_root_disk_size" {
  default = 40
}

variable "windows_count" {
  default = 1
}

variable "windows_ingress_rules" {
  type    = list(string)
  default = ["rdp-tcp"]
}

########### connection details ##################

variable "user_name" {
  type    = string
}

variable "user_pass" {
  type    = string
  default = ""
}

variable "windows_user_name" {
  type    = string
  default = ""
}
variable "windows_user_pass" {
  type    = string
  default = ""
}

variable "create_user" {
  default = false
}

variable "user_public_key" {
  type    = string
  default = ""
}

variable "user_private_key" {
  type    = string
  default = ""
}
