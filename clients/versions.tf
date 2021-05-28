###########################################################
# Configure Terraform and Providers Global Settings
terraform {
  required_version = "~> 0.15.3"
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "~> 2.21.0"
    }
  }
}