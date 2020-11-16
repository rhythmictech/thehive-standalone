output "elb_security_group_id" {
  description = "ARN of the ELB SG"
  value       = try(aws_security_group.alb[0].id, "")
}

output "lb_arn" {
  description = "ARN of the ELB"
  value       = try(aws_lb.this[0].arn, "")
}

output "lb_listener_arn" {
  description = "ARN of the ELB Listener"
  value       = try(aws_lb_listener.this[0].arn, "")
}

output "lb_target_group_arn" {
  description = "ARN of the ELB Target Group"
  value       = try(aws_lb_target_group.this[0].arn, "")
}

output "lb_dns_name" {
  description = "DNS Name of the ELB"
  value       = try(aws_lb.this[0].dns_name, "")
}

output "lb_zone_id" {
  description = "Route53 Zone ID of the ELB"
  value       = try(aws_lb.this[0].zone_id, "")
}

output "thehive_instance_id" {
  description = "Instance ID"
  value       = aws_instance.this.id
}

output "thehive_datavol_id" {
  description = "Data Volume ID"
  value       = aws_ebs_volume.this.arn
}

output "thehive_instance_ip" {
  description = "Instance ID"
  value       = aws_instance.this.private_ip
}