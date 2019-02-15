
all: clean build

clean:
	vagrant destroy -f
	rm -rf .vagrant

build:
	vagrant up --provision

sync_and_build:
	vagrant rsync
	vagrant up --provision
