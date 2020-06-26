
resource "aws_iam_role" "poc" {
  name = "${var.namespace}-iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "poc" {
  name = "${var.namespace}-iam_instance_profile"
  role = aws_iam_role.poc.name
}

#Policies here: S3 access for TFE storage and STS assume role for Workspaces to assume role instead of having IAM user keys
data "aws_iam_policy_document" "poc" {
  
  statement {
    sid    = "describeBuckets"
    effect = "Allow"

    resources = ["*"]

    actions = [
       "ec2:DescribeInstances"
    ]
  }
}

resource "aws_iam_role_policy" "poc" {
  name   = "${var.namespace}-iam_role_policy"
  role   = aws_iam_role.poc.name
  policy = data.aws_iam_policy_document.poc.json
}
