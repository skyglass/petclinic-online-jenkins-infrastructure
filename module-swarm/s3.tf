resource "aws_s3_bucket" "swarm_discovery_bucket" {
  bucket = var.swarm_discovery_bucket

  tags = {
    Author = var.author
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "swarm_discovery_bucket" {
  bucket = var.swarm_discovery_bucket
  acl = "private"
}