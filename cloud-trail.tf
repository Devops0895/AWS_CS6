# this is file consists cloud trail service
# It will log the tasks/actions performed on EC2 instance and S3 bucket

resource "aws_iam_policy" "cs6_cloudtrail_to_access_s3" {
  name        = "cs6-cloudtrail-access-s3"
  description = "cloud triail to access s3 buckets to put the logs"

  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
    ],
      "Resource": [
        "*"
    ]
  }
 ]
}
EOF
}

resource "aws_iam_role" "cs6-cloudtrail-to-access-s3-role" {
  name               = "CloudtrailS3AccessRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMroleForCloudtrailToAccessS3",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "cs6-cloudtrail-to-access-s3" {
  policy_arn = aws_iam_policy.cs6_cloudtrail_to_access_s3.arn
  role       = aws_iam_role.cs6-cloudtrail-to-access-s3-role.name
}


resource "aws_cloudtrail" "my-demo-cloudtrail" {
  name                          = "my-demo-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cs6-logging-bucket.id
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.ct-logging-key.arn
  depends_on                    = [aws_s3_bucket_policy.cs6_ec2_s3_access_policy, aws_s3_bucket.cs6-logging-bucket, aws_kms_key.ct-logging-key]
}