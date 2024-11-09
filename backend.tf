terraform {
  backend "s3" {
    bucket         = "mario-k8s-state-bucket"
    key            = "hanuma/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "mario-k8s-state-lock"
  }
}