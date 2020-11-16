data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
      effect = "Allow"
      resources = ["arn:aws:logs:*:*:*"]

    actions   = [
        "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
    ]
    
  }
  statement {
      effect = "Allow"

      actions = [
"ec2:AttachVolume",
                "ec2:DetachVolume"
      ]
      resources = [
aws_ebs_volume.this.arn,
                aws_instance.this.arn
      ]

      condition {
          test = "ArnEquals"
          values = [aws_instance.this.arn]
          variable = "ec2:SourceInstanceARN"
      }
  }
}

resource "aws_iam_policy" "this" {
  name_prefix = "thehive-ec2-policy"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "this" {
  name_prefix = "thehive_role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  path        = "/"
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "thehive_instance_profile"
  role        = aws_iam_role.this.name
}

