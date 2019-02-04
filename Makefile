
all:
	build

build:
	packer build -var-file=local_config.json packer-thehive-standalone.json
