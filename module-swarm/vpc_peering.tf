provider "aws" {
  alias = "accepter"
  region  = var.region
}

provider "aws" {
  alias = "owner"
  region  = var.region
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.jenkins_vpc_id
}

data "aws_vpc" "owner" {
  provider = aws.owner
  id       = aws_vpc.sandbox.id
}

locals {
  accepter_vpc_id     = data.aws_vpc.accepter.id
  owner_vpc_id        = data.aws_vpc.owner.id
  accepter_account_id = element(split(":", data.aws_vpc.accepter.arn), 4)
  owner_account_id    = element(split(":", data.aws_vpc.owner.arn), 4)
}

data "aws_route_tables" "owner" {
  provider = aws.owner
  vpc_id   = local.owner_vpc_id
}

data "aws_route_tables" "accepter" {
  provider = aws.accepter
  vpc_id   = local.accepter_vpc_id
}

resource "aws_vpc_peering_connection" "owner" {
  provider      = aws.owner
  vpc_id        = local.owner_vpc_id
  peer_vpc_id   = local.accepter_vpc_id
  peer_owner_id = local.accepter_account_id
  tags = {
    Name = "peer_to_accepter"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  auto_accept               = true
  tags = {
    Name = "peer_to_owner"
  }
}

resource "aws_route" "owner" {
  provider                  = aws.owner
  count                     = 3
  route_table_id            = tolist(data.aws_route_tables.owner.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
}
resource "aws_route" "accepter" {
  provider                  = aws.accepter
  count                     = 3
  route_table_id            = tolist(data.aws_route_tables.accepter.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.owner.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
} 