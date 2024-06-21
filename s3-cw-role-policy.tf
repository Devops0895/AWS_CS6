# Create IAM role for EC2 instances
resource "aws_iam_role" "s3_cw_access_role" {
  name               = "EC2S3AccessRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Update the IAM policy for S3 access
resource "aws_iam_policy" "case_s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy for EC2 S3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "s3:Delete*"
      ],
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "cw-agent-ec2-policy" {
  name        = "ec2-cw-access-policy"
  description = "Policy for Ec2 instance to access cloudwatch to send logs"

  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "*"
    ]
  }
 ]
}
EOF
}

# Attach the updated IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment_role" {
  policy_arn = aws_iam_policy.case_s3_access_policy.arn
  role       = aws_iam_role.s3_cw_access_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_cw_access_policy_attachment_role" {
  policy_arn = aws_iam_policy.cw-agent-ec2-policy.arn
  role       = aws_iam_role.s3_cw_access_role.name
}