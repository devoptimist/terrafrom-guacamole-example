terraform {
  required_version = "> 0.12.0"
}

provider "aws" {
  shared_credentials_file = "${var.aws_creds_file}"
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
}

resource "random_id" "hash" {
  byte_length = 4
}

locals {
  common_name = "${lookup(var.tags, "prefix", "changeme")}-${random_id.hash.hex}"
}

module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "2.9.0"
  name                    = "${local.common_name}-chef-vpc"
  cidr                    = var.vpc_cidr
  azs                     = var.vpc_azs
  public_subnets          = var.vpc_public_subnets
  map_public_ip_on_launch = true
  tags                    = var.tags
}

module "win_infra" {
  source                      = "devoptimist/workshop-server/aws"
  version                     = "0.0.1"
  key_name                    = var.key_name
  create_user                 = var.create_user
  user_name                   = var.windows_user_name
  user_pass                   = var.windows_user_pass
  sec_grp_ingress_rules       = var.windows_ingress_rules
  sec_grp_ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  server_count                = var.windows_count
  server_image_name           = var.windows_image_name
  server_image_owner          = var.windows_image_owner
  server_root_disk_size       = var.windows_root_disk_size
  server_instance_type        = var.windows_instance_type
  subnets                     = module.vpc.public_subnets
  instance_name               = "win"
  vpc_id                      = module.vpc.vpc_id
  system_type                 = "windows"
  tags                        = var.tags
}

module "linux_infra" {
  source                      = "devoptimist/workshop-server/aws"
  version                     = "0.0.1"
  key_name                    = var.key_name
  create_user                 = var.create_user
  user_name                   = var.user_name
  user_public_key             = var.user_public_key
  sec_grp_ingress_rules       = var.linux_ingress_rules
  sec_grp_ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  server_count                = var.linux_count
  user_private_key            = var.user_private_key
  server_image_name           = var.linux_image_name
  server_image_owner          = var.linux_image_owner
  server_instance_type        = var.linux_instance_type
  subnets                     = module.vpc.public_subnets
  instance_name               = "linux"
  vpc_id                      = module.vpc.vpc_id
  tags                        = var.tags
}

module "guacamole_infra" {
  source                = "devoptimist/workshop-server/aws"
  version               = "0.0.1"
  server_count          = var.guacamole_count
  server_image_name     = var.guacamole_image_name
  server_image_owner    = var.guacamole_image_owner
  server_instance_type  = var.guacamole_instance_type
  key_name              = var.key_name
  create_user           = var.create_user
  user_name             = var.user_name
  user_public_key       = var.user_public_key
  sec_grp_ingress_rules = var.guacamole_ingress_rules
  subnets               = module.vpc.public_subnets
  instance_name         = var.guacamole_hostname
  vpc_id                = module.vpc.vpc_id
  tags                  = var.tags
}

locals {
  guacamole_records = { for ip in module.guacamole_infra.server_public_ip : "${var.guacamole_hostname}-${index(module.guacamole_infra.server_public_ip, ip)}" => ip }
  con_n = [
    {
      "ui_user" = module.linux_infra.guacamole_user,
      "ui_pass" = module.linux_infra.guacamole_pass,
      "connections" = concat(module.linux_infra.guacamole_connections, module.win_infra.guacamole_connections)
    }
 ]
}

module "guacamole_dns_and_cert" {
  source         = "devoptimist/record-certs/dnsimple"
  version        = "0.0.1"
  records        = local.guacamole_records
  instance_count = var.guacamole_count
  contact        = lookup(var.tags, "contact")
  domain_name    = var.dnsimple_domain_name
  issuer_url     = var.issuer_url
  oauth_token    = var.dnsimple_oauth_token
  account        = var.dnsimple_account
}

module "guacamole_server" {
  source                                 = "devoptimist/apache-guacamole/linux"
  version                                = "0.0.3"
  ips                                    = module.guacamole_infra.server_public_ip
  instance_count                         = var.guacamole_count
  user_name                              = var.user_name
  user_private_key                       = var.user_private_key
  guacamole_client_connection_config     = local.con_n
  guacamole_client_tomcat_listen_address = "127.0.0.1"
  guacamole_webserver_hostname           = module.guacamole_dns_and_cert.certificate_domain[0]
  guacamole_webserver_ssl_crt            = module.guacamole_dns_and_cert.certificate_pem[0]
  guacamole_webserver_ssl_key            = module.guacamole_dns_and_cert.private_key_pem[0]
}
