
all: build

clean:
	/bin/rm packer_vars.json
	
build:
	cat local_config.json |jq '[ to_entries[] | select(.key | startswith("packer")) ] | from_entries' > packer_vars.json
	packer build -var-file=packer_vars.json packer-thehive-standalone.json
