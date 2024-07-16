# Output the public IP addresses of the instances in the Auto Scaling Group
output "instance_public_ips" {
  value       = data.aws_instances.example_instances.public_ips
  description = "The public IP addresses of the instances in the Auto Scaling Group"
}
