resource "aws_security_group" "this" {
  name_prefix = "thehive"

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "allow_inbound" {
  count = var.alb_create ? 1 : 0

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = var.allowed_access_cidrs

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "allow_inbound_from_lb" {
  count = var.alb_create ? 1 : 0

  protocol                 = "tcp"
  from_port                = 80
  security_group_id        = aws_security_group.this.id
  source_security_group_id = aws_security_group.alb[0].id
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group" "alb" {
  count = var.alb_create ? 1 : 0

  name_prefix = "thehive-lb"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_access_cidrs
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.this.id]
  }

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_lb_to_instance" {
  from_port   = 80
  protocol    = "tcp"
security_group_id = aws_security_group.alb[0].id
  source_security_group_id = aws_security_group.this.id
  to_port     = 80
  type        = "egress"
}

resource "aws_security_group_rule" "allow_access_to_lb" {
  count = var.alb_create ? 1 : 0

  cidr_blocks = var.allowed_access_cidrs
  from_port   = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.alb[0].id
  to_port     = 443
  type        = "ingress"
}

resource "aws_lb" "this" {
  count = var.alb_create ? 1 : 0

  name_prefix                      = "thehiv"
  enable_cross_zone_load_balancing = "true"
  internal                         = var.alb_internal
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb[0].id]
  subnets                          = var.alb_subnets
  tags                             = var.tags
}

resource "aws_lb_listener" "this" {
  count = var.alb_create ? 1 : 0

  certificate_arn   = var.alb_certificate
  load_balancer_arn = aws_lb.this[0].id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.this[0].id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "this" {
  count = var.alb_create ? 1 : 0

  name_prefix = "thehiv"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = "80"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = var.alb_create ? 1 : 0
  
  port             = 80
  target_group_arn = aws_lb_target_group.this[0].arn
  target_id        = aws_instance.this.id
}

resource "aws_route53_record" "thehive_alb" {
  count = var.r53_create && var.alb_create ? 1 : 0

  name    = var.r53_thehive_name
  type    = "A"
  zone_id = var.r53_zone

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "thehive_instance" {
  count = var.r53_create && ! var.alb_create ? 1 : 0

  name    = var.r53_thehive_name
  records = [aws_instance.this.private_ip]
  ttl     = "60"
  type    = "A"
  zone_id = var.r53_zone
}

resource "aws_route53_record" "cortex_alb" {
  count = var.r53_create && var.alb_create ? 1 : 0

  name    = var.r53_cortex_name
  type    = "A"
  zone_id = var.r53_zone

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cortext_instance" {
  count = var.r53_create && ! var.alb_create ? 1 : 0

  name    = var.r53_cortex_name
  records = [aws_instance.this.private_ip]
  ttl     = "60"
  type    = "A"
  zone_id = var.r53_zone
}

