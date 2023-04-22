module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = data.terraform_remote_state.project.outputs.prefix
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true
  # cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  enable_irsa = true
  # control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]


  # EKS Managed Node Group(s)
  # eks_managed_node_group_defaults = {
  #   instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  # }

  # eks_managed_node_groups = {
  #   blue = {}
  #   green = {
  #     min_size     = 1
  #     max_size     = 10
  #     desired_size = 1

  #     instance_types = ["t3.large"]
  #     capacity_type  = "SPOT"
  #   }
  # }



  # aws-auth configmap
  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t3.large", "t3x.large", "m5.large", "t3a.large", "t3a.xlarge"]
  }

  eks_managed_node_groups = {
    standard-node-group = {
      # ami_id = var.ami_id
      # This will ensure the boostrap user data is used to join the node
      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      # enable_bootstrap_user_data = true

      min_size     = 2
      max_size     = 10
      desired_size = 2

      disable_api_termination = false
      ebs_optimized           = true
      enable_monitoring       = true

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = 50
      }

      k8s_labels = data.terraform_remote_state.project.outputs.tags
      lables     = data.terraform_remote_state.project.outputs.tags

      # labels = {
      #   Environment = "test"
      #   GithubRepo  = "terraform-aws-eks"
      #   GithubOrg   = "terraform-aws-modules"
      # }

      # taints = [
      #   {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # ]

      tags = data.terraform_remote_state.project.outputs.tags
    }
  }

  # aws_auth_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]

  # aws_auth_users = [
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user1"
    #   username = "user1"
    #   groups   = ["system:masters"]
    # },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  # ]

  # aws_auth_accounts = [
    # "777777777777",
    # "888888888888",
  # ]

   # Extend cluster security group rules
  # cluster_security_group_additional_rules = {
  #   egress_nodes_ephemeral_ports_tcp = {
  #     description                = "To node 1025-65535"
  #     protocol                   = "tcp"
  #     from_port                  = 1025
  #     to_port                    = 65535
  #     type                       = "egress"
  #     source_node_security_group = true
  #   }
  # }

  # Extend node-to-node security group rules
  # node_security_group_additional_rules = {
  #   ingress_self_all = {
  #     description = "Node to node all ports/protocols"
  #     protocol    = "-1"
  #     from_port   = 0
  #     to_port     = 0
  #     type        = "ingress"
  #     self        = true
  #   }

    # controlplane_to_nodegroup_alb = { # https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2460
    #   description                   = "Controlplane to node on port 9443 for ALB controller"
    #   protocol                      = "TCP"
    #   from_port                     = 9443
    #   to_port                       = 9443
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # }

    # controlplane_to_nodegroup_ingress = { # https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2460
    #   description                   = "Controlplane to node on port 9443 for ALB controller"
    #   protocol                      = "TCP"
    #   from_port                     = 8443
    #   to_port                       = 8443
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # }

  #   egress_all = {
  #     description      = "Node all egress"
  #     protocol         = "-1"
  #     from_port        = 0
  #     to_port          = 0
  #     type             = "egress"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #   }
  # }

  tags = data.terraform_remote_state.project.outputs.tags
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}
