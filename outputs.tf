output "thehive_instance_id" {
  description = "Instance ID"
  value       = "${aws_instance.instance.id}"
}

output "thehive_datavol_id" {
  description = "Data Volume ID"
  value       = "${aws_ebs_volume.data_vol.arn}"
}

output "thehive_instance_ip" {
  description = "Instance ID"
  value       = "${aws_instance.instance.private_ip}"
}
