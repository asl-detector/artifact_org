# Create ECR repository
resource "aws_ecr_repository" "model_repository" {
  
  name     = "${var.project_name}/model"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

# # Create S3 bucket for model artifacts
# resource "aws_s3_bucket" "artifact_bucket" {
  
#   bucket   = "${var.project_name}-model-artifacts-${var.uuid}"
  
#   tags = {
#     Name = "${var.project_name}-model-artifacts"
#   }
# }

# # Create SageMaker Model Registry
# resource "aws_sagemaker_model_package_group" "model_package_group" {
#   
#   model_package_group_name = "${var.project_name}-models"
  
#   model_package_group_description = "Model package group for ${var.project_name} models"
# }

# # Create EventBridge Rule for Model Registry events
# resource "aws_cloudwatch_event_rule" "model_registry_events" {
#   
#   name        = "${var.project_name}-model-registry-events"
#   description = "Capture model approval events"
  
#   event_pattern = jsonencode({
#     source      = ["aws.sagemaker"],
#     detail-type = ["SageMaker Model Package State Change"],
#     detail      = {
#       ModelPackageGroupName = [aws_sagemaker_model_package_group.model_package_group.model_package_group_name],
#       ModelApprovalStatus   = ["Approved"]
#     }
#   })
# }

# # Set up EventBridge target to notify Operations account
# resource "aws_cloudwatch_event_target" "notify_operations" {
#   
#   rule      = aws_cloudwatch_event_rule.model_registry_events.name
#   target_id = "SendToOperations"
#   arn       = aws_sns_topic.model_approval_topic.arn
# }

# # Create SNS topic for model approvals
# resource "aws_sns_topic" "model_approval_topic" {
#   name     = "${var.project_name}-model-approvals"
# }

# # Resource policy for cross-account access to model registry
# resource "aws_sagemaker_model_package_group_policy" "cross_account_access" {
#   
#   model_package_group_name = aws_sagemaker_model_package_group.model_package_group.model_package_group_name
  
#   resource_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           AWS = [
#             "arn:aws:iam::${var.development_account_id}:root",
#             "arn:aws:iam::${var.operations_account_id}:root",
#             "arn:aws:iam::${var.cicd_account_id}:root"
#           ]
#         }
#         Action = [
#           "sagemaker:DescribeModelPackageGroup",
#           "sagemaker:DescribeModelPackage",
#           "sagemaker:ListModelPackages",
#           "sagemaker:UpdateModelPackage"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
