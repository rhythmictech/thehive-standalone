resource "aws_security_group" "thehive_sg" {
  name_prefix = "thehive"

  vpc_id                  = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.thehive_sg.id}"
}

resource "aws_security_group_rule" "allow_inbound" {
  count           = "${1 - var.alb_create}"
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 80
  to_port         = 80
  cidr_blocks     = ["${var.allowed_access_cidrs}"]

  security_group_id = "${aws_security_group.thehive_sg.id}"
}

resource "aws_security_group_rule" "allow_inbound_from_lb" {
  count           = "${var.alb_create}"
  type            = "ingress"
  protocol        = "tcp"
  from_port       = 80
  to_port         = 80
  source_security_group_id = "${aws_security_group.thehive_alb_sg.id}"

  security_group_id = "${aws_security_group.thehive_sg.id}"
}

resource "aws_security_group" "thehive_alb_sg" {
  name_prefix = "thehive"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.allowed_access_cidrs}"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.thehive_sg.id}"]
  }

  vpc_id                  = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "thehive_alb" {
  count                   = "${var.alb_create}"
  name_prefix             = "thehiv"
  enable_cross_zone_load_balancing = "true"
  internal                = "${var.alb_internal}"
  load_balancer_type      = "application"

  security_groups         = ["${aws_security_group.thehive_alb_sg.id}"]
  subnets                 = ["${var.alb_subnets}"]

  tags = "${var.tags}"
}

resource "aws_lb_listener" "thehive_alb_listener" {
  count                   = "${var.alb_create}"
  load_balancer_arn       = "${aws_lb.thehive_alb.id}"
  port                    = "443"
  protocol                = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.alb_certificate}"

  default_action {
    target_group_arn      = "${aws_lb_target_group.thehive_alb_tg.id}"
    type                  = "forward"
  }
}

resource "aws_lb_target_group" "thehive_alb_tg" {
  count                   = "${var.alb_create}"
  name_prefix              = "thehiv"

  port                    = "80"
  protocol                = "HTTP"

  vpc_id                  = "${var.vpc_id}"

  health_check {
      protocol = "HTTP"
      port     = "80"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_lb_target_group_attachment" "thehive" {
  target_group_arn = "${aws_lb_target_group.thehive_alb_tg.arn}"
  target_id        = "${aws_instance.instance.id}"
  port             = 80
}


resource "aws_route53_record" "thehive_dns_name_alb" {
  count                   = "${var.r53_create * var.alb_create}"
  zone_id                 = "${var.r53_zone}"
  name                    = "${var.r53_thehive_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.thehive_alb.dns_name}"
    zone_id                = "${aws_lb.thehive_alb.zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "thehive_dns_name_instance" {
  count                   = "${var.r53_create * (1 - var.alb_create)}"
  zone_id                 = "${var.r53_zone}"
  name                    = "${var.r53_thehive_name}"
  type    = "A"
  ttl     = "60"

  records = ["${aws_instance.instance.private_ip}"]
}

resource "aws_route53_record" "cortex_dns_name_alb" {
  count                   = "${var.r53_create * var.alb_create}"
  zone_id                 = "${var.r53_zone}"
  name                    = "${var.r53_cortex_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.thehive_alb.dns_name}"
    zone_id                = "${aws_lb.thehive_alb.zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "cortex_dns_name_instance" {
  count                   = "${var.r53_create * (1 - var.alb_create)}"
  zone_id                 = "${var.r53_zone}"
  name                    = "${var.r53_cortex_name}"
  type    = "A"
  ttl     = "60"

  records = ["${aws_instance.instance.private_ip}"]
}
