locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Cluster     = var.cluster_name
    },
    var.tags
  )
}

########################
# IAM PARA NODOS SELF-MANAGED
########################

resource "aws_iam_role" "node_role" {
  name = "${var.project_name}-${var.environment}-eks-self-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "node_profile" {
  name = "${var.project_name}-${var.environment}-eks-self-nodes-profile"
  role = aws_iam_role.node_role.name

  tags = local.common_tags
}

########################
# SECURITY GROUP PARA NODOS
########################

resource "aws_security_group" "nodes_sg" {
  name        = "${var.project_name}-${var.environment}-eks-self-nodes-sg"
  description = "Security Group para nodos self-managed de EKS"
  vpc_id      = var.vpc_id

  egress {
    description = "Todo el tráfico saliente permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-self-nodes-sg"
  })
}

# Reglas de ejemplo: permitir tráfico dentro del SG (entre nodos)
resource "aws_security_group_rule" "nodes_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.nodes_sg.id
  self              = true
}

########################
# USER DATA (BOOTSTRAP)
########################

# IMPORTANTE:
# Este script asume que la AMI de Packer está basada en una imagen compatible con EKS
# y que existe el script de bootstrap /etc/eks/bootstrap.sh o equivalente.
locals {
  user_data = <<-EOT
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name}
  EOT
}

########################
# LAUNCH TEMPLATE
########################

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-eks-self-nodes-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = length(var.ssh_key_name) > 0 ? var.ssh_key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.node_profile.name
  }

  network_interfaces {
    security_groups = concat(
      [aws_security_group.nodes_sg.id],
      var.additional_security_group_ids
    )
    associate_public_ip_address = false
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-eks-self-node"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = local.common_tags
  }

  tags = local.common_tags
}

########################
# AUTO SCALING GROUP
########################

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project_name}-${var.environment}-eks-self-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Etiquetas requeridas por EKS (muy importante)
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  # Tags comunes del proyecto
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
