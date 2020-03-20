
# Terraform example

This example creates the following AWS components:
- VPC (with 2 private and 2 public Subnets)
- Internet Gateway
- NAT Gateway (Optional)
- Application Load Balancer
- Auto Scaling Group
- 2 EC2 instances* (with a simple HTTP test program)
- RDS database

Additionally, if you store the Terraform state file remotely, it will also create:
- S3 bucket
- DynamoDB table

(\*) If you are using the AWS Free Tier, you will be limited to 1 EC2 instances. Open a support case to request increase this limit.

## Configure the AWS credentials
You will need a IAM user account with these minimum permission policies:
- AmazonEC2FullAccess
- AmazonS3FullAccess
- AmazonDynamoDBFullAccess
- AmazonRDSFullAccess

Set your AWS enviroment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` and `AWS_DEFAULT_REGION`

## Storing the state remotely
Follow these steps to store your tfstate file on AWS S3:
1. Copy `state.tf` to the root folder of your project
1. Edit `state.tf` and set your bucket, key and DynamoDB table name.
1. Run `terraform init` to download the provider code and then run `terraform apply` to deploy.
1. Now, edit again `state.tf` and uncomment the terraform backend section.
1. Run `terraform init` again. Terraform will automatically detect that you already have a state file locally and prompt you to copy it to the new S3 backend.

If you ever wanted to delete the resources, you’d have to do the reverse process:
1. Edit `state.tf` and comment the terraform backend section.
1. Run `terraform init` to copy the Terraform state back to your local disk.
1. Run `terraform destroy` to delete all the resources.

If you get the `BucketNotEmpty` error, you must delete all the contents and versions in the bucket.
