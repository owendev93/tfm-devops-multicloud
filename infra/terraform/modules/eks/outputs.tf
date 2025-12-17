output "cluster_name" {
  description = "Nombre del clúster EKS"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint del clúster EKS"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA del clúster EKS (base64)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security Group del control plane EKS"
  value       = aws_security_group.eks_cluster_sg.id
}

output "nodes_security_group_id" {
  description = "Security Group de los nodos EKS"
  value       = aws_security_group.eks_nodes_sg.id
}

output "node_group_name" {
  description = "Nombre del Managed Node Group de EKS"
  value       = aws_eks_node_group.this.node_group_name
}
