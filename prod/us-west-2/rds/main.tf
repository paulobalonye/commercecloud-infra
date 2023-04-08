locals {
  instance_type = "db.t3.micro"
  multi_az      = true
  mysql_version = "5.7"
}

resource "aws_security_group" "main_rds_sg" {
  name        = "${data.terraform_remote_state.project.outputs.prefix}-rds-sg"
  description = "RDS security group for ${data.terraform_remote_state.project.outputs.prefix}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = data.terraform_remote_state.project.outputs.tags

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "db_instance" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.6.0"

  identifier              = data.terraform_remote_state.project.outputs.prefix
  engine                  = "mysql"
  engine_version          = local.mysql_version
  major_engine_version    = local.mysql_version
  family                  = "mysql${local.mysql_version}"
  db_name                 = "main"
  username                = "admin"
  password                = "admin"
  instance_class          = local.instance_type
  allocated_storage       = 20
  vpc_security_group_ids  = [aws_security_group.main_rds_sg.id]
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  create_db_subnet_group  = true
  subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnets
  multi_az                = local.multi_az
  deletion_protection     = true
  tags                    = data.terraform_remote_state.project.outputs.tags
  backup_retention_period = 7
  apply_immediately       = true
}