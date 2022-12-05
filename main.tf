module "jenkins" {
  source = "./module-jenkins"

  region                 = var.aws_region
  author                 = "skyglass"
  public_key             = "../ssh-jenkins.pub"
  hosted_zone_id         = "Z00391621ABLUKSLON5HM"
  domain_name            = "greeta.net"
  ssl_arn                = "arn:aws:acm:eu-central-1:217264062492:certificate/e989836a-4a9a-4c87-bd05-6749fecb7958"
  jenkins_username       = "admin"
  jenkins_password       = "admin"
  jenkins_credentials_id = "jenkins-slaves"
}

module "swarm" {
  source = "./module-swarm"

  region                 = var.aws_region
  environment            = "sandbox"
  author                 = "skyglass"
  key_name               = module.jenkins.key_pair_management_id
  bastion_sg_id          = module.jenkins.bastion_sg_id
  jenkins_sg_id          = module.jenkins.jenkins_sg_id
  jenkins_vpc_id         = module.jenkins.jenkins_vpc_id
}

module "app" {
  source = "./module-app"

  region                 = var.aws_region
  environment            = "sandbox"
  author                 = "skyglass"
  hosted_zone_id         = "Z00391621ABLUKSLON5HM"
  domain_name            = "greeta.net"
  ssl_arn                = "arn:aws:acm:eu-central-1:217264062492:certificate/e989836a-4a9a-4c87-bd05-6749fecb7958"
  vpc_id                 = module.swarm.swarm_vpc_id
  public_subnets         = module.swarm.swarm_public_subnets
  swarm_managers_asg_id  = module.swarm.managers_asg_id
  swarm_workers_asg_id   = module.swarm.workers_asg_id
}