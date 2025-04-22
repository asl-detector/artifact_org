resource "aws_s3_bucket" "model_serving_bucket" {
  bucket = "${var.project_name}-model-serving-${var.uuid}"

  tags = {
    Name = "${var.project_name}-model-serving"
  }
}

resource "aws_s3_bucket_policy" "model_serving_bucket_policy" {
  bucket = aws_s3_bucket.model_serving_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${local.account_ids.staging}:root",
            "arn:aws:iam::${local.account_ids.production}:root"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.model_serving_bucket.arn}",
          "${aws_s3_bucket.model_serving_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Allow public read access to the bucket
resource "aws_s3_bucket_public_access_block" "model_serving_bucket" {
  bucket = aws_s3_bucket.model_serving_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "model_serving_lambda_role" {
  name = "model-serving-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
        AWS = [
          "arn:aws:iam::${local.account_ids.staging}:root",
          "arn:aws:iam::${local.account_ids.production}:root"
        ]
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_s3_model_serving_policy" {
  name = "lambda-s3-model-serving-policy"
  role = aws_iam_role.model_serving_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.model_serving_bucket.arn}",
          "${aws_s3_bucket.model_serving_bucket.arn}/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetBucketLocation"
        Resource = "*" # Required for SDK operations
      }
    ]
  })
}

resource "aws_iam_role" "operations_upload_role" {
  name = "operations-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.terraform_remote_state.org_structure.outputs.account_ids.operations}:root"
      }
    }]
  })
}

resource "aws_iam_role_policy" "operations_upload_policy" {
  name = "operations-upload-policy"
  role = aws_iam_role.operations_upload_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.model_serving_bucket.arn,
        "${aws_s3_bucket.model_serving_bucket.arn}/*"
      ]
    }]
  })
}

output "model_serving_bucket_name" {
  value = aws_s3_bucket.model_serving_bucket.id
}

output "model_serving_lambda_role_arn" {
  value = aws_iam_role.model_serving_lambda_role.arn
}

output "operations_upload_role_arn" {
  value       = aws_iam_role.operations_upload_role.arn
  description = "ARN of the role that operations account can assume to upload models"
}

