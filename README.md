# Artifact Organization

This module manages artifact storage and related infrastructure for the ASL Dataset project, including:

- Model registry for machine learning models
- Container registry for Docker images
- Model serving infrastructure
- Storage buckets for shared artifacts

## Components

- `container_registry.tf` - AWS ECR configuration for Docker containers
- `model_registry.tf` - SageMaker model registry configuration
- `model_serving_bucket.tf` - S3 bucket configuration for model serving
- `terraform_remote_state.tf` - Configuration for remote state access

## Usage

Deploy this module to set up the artifact storage infrastructure required by the ASL Dataset project's ML pipeline.

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

The module exports various IDs, ARNs, and URLs for the resources it creates, which are used by other parts of the infrastructure.