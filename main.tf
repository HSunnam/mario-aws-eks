#-------------------------------------------
# main.tf
# - main terraform module functionality
#--------------------------------------------

# EC2 Instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.project_name}-ec2-instance"

  ami                    = var.ami_id
  instance_type          = var.instance_type
  monitoring             = true
  key_name               = var.key_pair
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ec2-instance"
    }
  )
}

# S3 bucket for the state file
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "${var.project_name}-state-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Prevent accidental deletion
  force_destroy = false

  tags = var.common_tags
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.project_name}-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.common_tags
}