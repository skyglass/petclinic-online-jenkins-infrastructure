output "managers_asg_id" {
  value = aws_autoscaling_group.swarm_managers.name
}

output "workers_asg_id" {
  value = aws_autoscaling_group.swarm_workers.name
}

output "swarm_vpc_id" {
  value = aws_vpc.sandbox.id
}

output "swarm_public_subnets" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}