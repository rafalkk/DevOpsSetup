terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.7.0"
    }
  }

/* Organization and workspace name for Terraform Cloud services. */
  cloud {
    organization = ""

    workspaces {
      name = ""
    }
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

/* Network */

resource "oci_core_virtual_network" "lab_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = var.core_virtual_network_name
  dns_label      = var.core_virtual_network_label
}

resource "oci_core_subnet" "lab_subnet" {
  cidr_block        = "10.1.20.0/24"
  display_name      = var.core_subnet_name
  dns_label         = var.core_subnet_label
  security_list_ids = [oci_core_security_list.lab_security_list.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.lab_vcn.id
  route_table_id    = oci_core_route_table.lab_route_table.id
  dhcp_options_id   = oci_core_virtual_network.lab_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "lab_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = var.core_internet_gateway_name
  vcn_id         = oci_core_virtual_network.lab_vcn.id
}

resource "oci_core_route_table" "lab_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.lab_vcn.id
  display_name   = var.core_route_table_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.lab_internet_gateway.id
  }
}

resource "oci_core_security_list" "lab_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.lab_vcn.id
  display_name   = var.core_security_list_name

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}

/* Instances */

resource "oci_core_instance" "free_instance" {
  count = 1
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.core_instance_name}_${count.index}"
  shape               = var.instance_shape
  
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "${var.core_instance_label}${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid_arm
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # Anyone with access to the terraform state file will see the private key used in the userdata-populated.sh script.
    user_data           = base64encode(file("./userdata-populated.sh"))
  }

}

/*
Workaround to force Terraform to update outputs without making any changes to the real infrastructure.
Timestamp changes every time so it should triggers the null_resource to be recreated.
Comment out when not needed
*/

resource "null_resource" "update_trigger" {
  triggers = {
    always_update = timestamp()
  }

  # Use a dummy provisioner to ensure the null_resource is always executed
  provisioner "local-exec" {
    command = "echo Trigger executed"
  }
}