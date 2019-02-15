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
        },
        {
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": [
                "${aws_ebs_volume.data_vol.arn}",
                "${aws_instance.instance.arn}"
            ],
            "Effect": "Allow",
            "Condition": {
                "ArnEquals": {"ec2:SourceInstanceARN": "${aws_instance.instance.arn}"}
            }
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
