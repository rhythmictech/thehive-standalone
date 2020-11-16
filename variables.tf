# Generic Vars
variable "tags" {
  description = "Tags to include on resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name for this host"
  type        = string
}

# Network related vars
variable "vpc_id" {
  description = "VPC that the host will be created in"
  type        = string
}

variable "allowed_access_cidrs" {
  description = "Allowed Access CIDRs (for TheHive access)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_subnet" {
  description = "Subnet to create instance in"
  type        = string
}

variable "availability_zone" {
  description = "AZ corresponding to subnet"
  type        = string
}

# Instance related vars
variable "instance_image" {
  description = "AMI to use for the bastion host instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion"
  type        = string
  default     = "t2.micro"
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = string
  default     = "false"
}

variable "instance_additional_sgs" {
  description = "Additional security groups"
  type        = list(string)
  default     = []
}

variable "keypair" {
  description = "Keypair to create instance with"
  type        = string
}

variable "ebs_volume_type" {
  description = "Data Volume Type"
  type        = string
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "Data Volume Size"
  type        = string
  default     = "100"
}

# ELB related vars
variable "alb_create" {
  description = "Create an ALB"
  type        = string
  default     = true
}

variable "alb_subnets" {
  description = "Subnets to create the ALB in (specify 3)"
  type        = list(string)
}

variable "alb_internal" {
  description = "Create the ALB on an internal (true) or internet-facing (false) scheme"
  type        = string
  default     = "true"
}

variable "alb_certificate" {
  description = "ACM to use for TheHive"
  type        = string
}

variable "r53_create" {
  description = "Create a Route 53 zone entry for the instance or ALB"
  type        = string
  default     = false
}

variable "r53_zone" {
  description = "Zone ID"
  type        = string
}

variable "r53_thehive_name" {
  description = "Host name to create for thehive (must be fully qualified)"
  type        = string
}

variable "r53_cortex_name" {
  description = "Host name to create for cortex (must be fully qualified)"
  type        = string
}

