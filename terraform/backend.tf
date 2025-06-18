terraform {
  backend "s3" {
    bucket         = "vin-cicd-tfstate"
    key            = "react-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "vin-cicd-lock-table"
    encrypt        = true
  }
}
