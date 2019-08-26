output "guacamole_user" {
  value = module.linux_infra.guacamole_user
}

output "guacamole_pass" {
  value = module.linux_infra.guacamole_pass
}

output "guacamole_address" {
  value = "http://${module.guacamole_infra.server_public_ip[0]}:8080/guacamole"
}

output "guacamole_webserver_address" {
  value = "https://${module.guacamole_dns_and_cert.certificate_domain[0]}"
}
output "guacamole_servers" {
  value = module.guacamole_infra.server_public_ip[0]
}
