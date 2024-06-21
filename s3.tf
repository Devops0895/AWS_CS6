# #iam policy for cloud trail role for logging events for ec2 and s3 bucket

# Create the S3 bucket in the cloud trail logging 
resource "aws_s3_bucket" "cs6-logging-bucket" {
  bucket        = "ec2-access-logging-bucket-112233"
  force_destroy = true

  tags = {
    Name        = "ec2-access-logging-bucket-112233"
    Environment = "test"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cs6-logging-bucket.bucket
  rule {
    id = "log"

    expiration {
      days = 90
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    actions = [
      "s3:GetBucketAcl",
    ]
    principals {
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      aws_s3_bucket.cs6-logging-bucket.arn,
    ]
    sid = "CloudTrail Acl Check"
  }

  statement {
    actions = [
      "s3:PutObject",
    ]
    condition {
      test = "StringEquals"
      values = [
        "bucket-owner-full-control",
      ]
      variable = "s3:x-amz-acl"
    }
    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }
    resources = [
      "${aws_s3_bucket.cs6-logging-bucket.arn}/*",
    ]
    sid = "CloudTrail Write"
  }

  statement {
    actions = [
      "s3:*",
    ]
    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.cs6-logging-bucket.arn,
      "${aws_s3_bucket.cs6-logging-bucket.arn}/*",
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "cs6_ec2_s3_access_policy" {
  bucket = aws_s3_bucket.cs6-logging-bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}






