# thehive-standalone

*This is not maintained. There are a number of better ways to run TheHive, particularly
thanks to better Docker support than when this was written. Also, there's better ways to
build and run using newer features in Terraform, Ansible, Packer, etc. Keeping this repo
for historical purposes, but you probably shouldn't use it.*

A combination of Terraform module, packer builder and ansible modules that
create a standalone installation of TheHive and Cortex in AWS. The intended
use is to create your own AMI and then create a deployed instance via
Terraform. Terraform will preserve the data volume between upgrades.

## Usage
To create an AMI, create a local_config.json file that is based on the
local_config.sample.json file. Not all variables are required (for example,
both ldap and vouch configs are included for clarity). A minimal config is below:

```json
{

  "aws_ami_filter_owner": "1234567890",
  "aws_ami_filter_name": "centos-7-base-*",
  "aws_ami_ssh_username": "ec2-user",
  "aws_ami_build_subnet": "subnet-123456",

  "cortex_url": "cortex.corp",
  "cortex_seed_initial_username": "admin",
  "cortex_crypto_secret": "...",
  "cortex_api_key": "apikey",

  "thehive_url": "thehive.corp",
  "thehive_seed_initial_username": "admin",


  "thehive_crypto_secret": "...",

  "thehive_cortex_servers": {
    "cortex": {
      "url": "http://127.0.0.1:9001/",
      "key": "apikey"
    }
  }
}

```

Note that the secret keys can be generated as follows:

```cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1```

The API key can be generated similarly:

```cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1```

Create the AMI by running the Makefile:

```make all```

A very simplified idea of how this would be created in terraform..

```yaml
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

```

## Vagrant
Vagrant can be used to test the build process. The supplied Vagrantfile in
the ansible directory will go through the same process as packer to provision
the instance. It can be used for troubleshooting. See the Makefile.
