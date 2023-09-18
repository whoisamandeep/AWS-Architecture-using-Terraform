resource "aws_iam_role" "s3_full_access_role" {
  name = "s3_full_access_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "s3_full_access_policy"
  description = "Full access to S3"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_full_access_attachment" {
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  name       = "s3_full_access_attachment"  # Add a name for the attachment
  roles      = [aws_iam_role.s3_full_access_role.name]
}

resource "aws_iam_instance_profile" "s3_full_access_instance_profile" {
  name = "s3_full_access_instance_profile"
  role = aws_iam_role.s3_full_access_role.name
}