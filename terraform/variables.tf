# OCI provider

variable "tenancy_ocid" {
  description = "Tenancy ocid where to create the sources"
  type        = string
}

variable "user_ocid" {
  description = "Ocid of user that terraform will use to create the resources"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of oci api private key"
  type        = string
}

variable "private_key_path" {
  description = "Path to oci api private key used"
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment ocid where to create all resources"
  type        = string
}

variable "region" {
  description = "The oci region where resources will be created"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see https://github.com/oracle-terraform-modules/terraform-oci-compute-instance/blob/main/docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}


# VM config

variable "core_instance_name" {
  type        = string
  description = "Name for the core_instance"
  default     = "lab_free_instance"
}

variable "core_instance_label" {
  type        = string
  description = "Name for the core_instance label"
  default     = "labfreeinstance"
}

variable "instance_shape" {
  description = "The shape of an instance. Could be 'VM.Standard.A1.Flex' or 'VM.Standard.E2.1.Micro'"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs. Max 4 in FreeTier"
  type        = number
  default     = 1
}

variable "instance_shape_config_memory_in_gbs" {
  description = "Amount of Memory (GB). Max 24 in FreeTier"
  type        = number
  default     = 6
}

variable "vm_image_ocid_arm" {
  description = "The OCID of the VM image to be deployed (arm)."
  type        = string
}


# virtual_network

variable "core_virtual_network_name" {
  type        = string
  description = "Name for the VCN"
  default     = "lab_vcn"
}

variable "core_virtual_network_label" {
  type        = string
  description = "Name for the VCN label"
  default     = "labVCN"
}

variable "core_subnet_name" {
  type        = string
  description = "Name for the core_subnet"
  default     = "lab_subnet"
}

variable "core_subnet_label" {
  type        = string
  description = "Name for the core_subnet label"
  default     = "labSUBNET"
}

variable "core_internet_gateway_name" {
  type        = string
  description = "Name for the core_internet_gateway"
  default     = "lab_IntenetGateway"
}

variable "core_route_table_name" {
  type        = string
  description = "Name for the core_route_table"
  default     = "lab_RouteTable"
}

variable "core_security_list_name" {
  type        = string
  description = "Name for the core_security_list"
  default     = "lab_SecurityList"
}



