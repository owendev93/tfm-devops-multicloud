output "asg_name" {
  description = "Nombre del Auto Scaling Group de nodos self-managed"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "ID del Launch Template usado por el ASG"
  value       = aws_launch_template.this.id
}

output "nodes_security_group_id" {
  description = "Security Group de los nodos self-managed"
  value       = aws_security_group.nodes_sg.id
}

output "node_role_arn" {
  description = "ARN del rol IAM usado por los nodos"
  value       = aws_iam_role.node_role.arn
}
