


resource "aws_security_group" "thehive_sg" {
  name_prefix = "thehive-${var.name}-sg"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id                  = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "iam_policy" {
  name_prefix        = "thehive-ec2-policy"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ],
            "Effect": "Allow"
        }

    ]
}
EOF
}

resource "aws_iam_role" "iam_role" {
  name_prefix = "thehive_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attach" {
  role       = "${aws_iam_role.iam_role.name}"
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "thehive_instance_profile"
  role = "${aws_iam_role.iam_role.name}"
}

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

}
