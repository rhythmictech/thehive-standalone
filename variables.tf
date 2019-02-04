# Generic Vars
variable "tags" {
  description = "Tags to include on resources"
  type        = "map"
  default     = {}
}

variable "name" {
  description = "Name for this host"
  type        = "string"
}

# Network related vars
variable "vpc_id" {
  description = "VPC that the host will be created in"
  type        = "string"
}

variable "instance_subnet" {
  description = "Subnet to create instance in"
  type        = "string"
}

variable "availability_zone" {
  description = "AZ corresponding to subnet"
  type        = "string"
}


# Instance related vars
variable "instance_image" {
  description = "AMI to use for the bastion host instances"
  type        = "string"
}

variable "instance_type" {
  description = "Instance type for the bastion"
  type        = "string"
  default     = "t2.micro"
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = "string"
  default     = "false"
}

variable "instance_additional_sgs" {
  description = "Additional security groups"
  type        = "list"
  default     = []
}

variable "keypair" {
  description = "Keypair to create instance with"
  type        = "string"
}

variable "ebs_volume_type" {
  description = "Data Volume Type"
  type        = "string"
  default = "gp2"
}

variable "ebs_volume_size" {
  description = "Data Volume Size"
  type        = "string"
  default = "100"
}
