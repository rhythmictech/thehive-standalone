# thehive-standalone

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

## Vagrant
Vagrant can be used to test the build process. The supplied Vagrantfile in
the ansible directory closely simulates the
