

locals {
  tag_map = {
    Name = "${var.name}"
  }
}

resource "aws_ebs_volume" "data_vol" {
  availability_zone = "${var.availability_zone}"

  type = "${var.ebs_volume_type}"
  size = "${var.ebs_volume_size}"

  tags = "${merge(local.tag_map, var.tags)}"
}





data "template_file" "init" {
  template = "${file("${path.module}/cloudinit/init.cfg")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.init.rendered}"
  }

  part {
    content_type = "text/cloud-boothook"
    content      = <<EOF
#!/bin/bash

exec > >(tee /var/log/user-data.log  2>/dev/console) 2>&1

INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

# wait for ebs volume to be attached
while true
do
    # attach EBS (run multiple times in case the volume was still detaching elsewhere)
    aws --region us-east-1 ec2 attach-volume --volume-id ${aws_ebs_volume.data_vol.id} --instance-id $INSTANCE_ID --device /dev/xvdg

    # see if the volume is mounted before proceeding
    lsblk |grep xvdg
    if [ $? -eq 0 ]
    then
        break
    else
        sleep 5
    fi
done

sleep 2

# create fs if needed
/sbin/parted /dev/xvdg print 2>/dev/null |grep Linux
if [ $? -eq 0 ]
then
  echo "Data partition found, ensuring it is mounted"

  mount | grep /data

  if [ $? -eq 1 ]
  then
    echo "Data partition not mounted, mounting and adding to fstab"
    echo "/dev/xvdg1 /data         xfs     defaults,noatime   1 1" >> /etc/fstab
    mount /data
  fi

else
  echo "Data partition not initialized. Initializing and moving base data volume"

  parted -s /dev/xvdg mklabel gpt
  parted -s /dev/xvdg mkpart primary xfs 0% 100%

  while true
  do
    lsblk |grep xvdg1
    if [ $? -eq 0 ]
    then
        break
    else
        sleep 5
    fi
  done

  mkfs.xfs /dev/xvdg1
  mount /dev/xvdg1 /mnt
  rsync -a /data/ /mnt
  umount /mnt

  echo "Data partition initialized, mounting and adding to fstab"

  echo "Data partition initialized, mounting and adding to fstab" > /dev/console
  echo "/dev/xvdg1 /data         xfs     defaults,noatime   1 1" >> /etc/fstab
  mount /data
fi
EOF
  }

}

resource "aws_instance" "instance" {
  monitoring                          = "${var.enable_monitoring}"
  iam_instance_profile                = "${aws_iam_instance_profile.instance_profile.id}"
  ami                                 = "${var.instance_image}"
  instance_type                       = "${var.instance_type}"
  key_name                            = "${var.keypair}"
  subnet_id                           = "${var.instance_subnet}"
  vpc_security_group_ids              = ["${concat(list(aws_security_group.thehive_sg.id), var.instance_additional_sgs)}"]

  tags = "${merge(local.tag_map, var.tags)}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  user_data_base64 = "${data.template_cloudinit_config.config.rendered}"
}
