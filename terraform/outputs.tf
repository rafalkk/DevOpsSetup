output "instances_public_ips" {
  value     = "${oci_core_instance.free_instance[*].public_ip}"
  sensitive = false
}

output "oci_identity_availability_domain_ad_name" {
  value     = data.oci_identity_availability_domain.ad.name
  sensitive = false
}