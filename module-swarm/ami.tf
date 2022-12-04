# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
}

// Find latest Docker AMI
data "aws_ami" "docker" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["docker-*"]
  }
}