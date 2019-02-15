local {

  region = "us-east-1"
  admin_access_sg_id = "sg-12345789"
  subnet = "subnet-12345678"
  keypair = "default"
  availability_zones = "az1"
  vpc_id = "vpc-12345678"


}

provider "aws" {
  region = "${local.region}"

}

data "aws_caller_identity" "current" {}


data "aws_ami" "thehive-latest" {
    most_recent = true

    filter {
        name   = "name"
        values = ["thehive-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["${data.aws_caller_identity.current.account_id}"]
}

module "thehive" {
  source    = "/Users/cdaniluk/dev/rhythmic/thehive-standalone"

  name = "thehive"

  instance_additional_sgs = ["${local.admin_access_sg_id}"]
  instance_image = "${data.aws_ami.thehive-latest.id}"
  instance_subnet = "${local.subnet}"
  instance_type = "t2.medium"
  keypair = "${local.keypair}"

  availability_zone = "${local.availability_zones}"
  vpc_id = "${local.vpc_id}"

  # Place instance behind an SSL-terminating ALB
  alb_create = true
  alb_subnets = ["subnet-12345678, subnet-23456789, subnect-34567890"]
  alb_internal = "true"
  alb_certificate = "arn:aws:acm:us-east-1:0123456790:certificate/..."

  # Create Route53 entries for thehive and cortex
  r53_create  = true
  r53_zone    = "Z12345679ASDF"
  r53_thehive_name    = "thehive.corp.local"
  r53_cortex_name    = "cortex.corp.local"
}
