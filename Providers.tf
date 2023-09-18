# Define the AWS provider configuration
provider "aws" {
  region = "us-east-1" # Specify your desired AWS region
  # You can also set other provider-specific configurations here, such as access keys and secret keys.
}

# Define the backend configuration to store state in an S3 bucket
terraform {
  backend "s3" {
    bucket  = "myterrastatefile"       # Replace with your S3 bucket name
    key     = "infrastructure.tfstate" # Specify the state file name
    region  = "us-east-1"              # Specify the AWS region of your S3 bucket
    encrypt = true                     # Enable encryption of state file
    # You can configure other backend settings here, such as DynamoDB locking tables and IAM roles.
  }
}
