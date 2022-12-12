provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  bastion_instance_type = var.bastion_instance_type
}

data "aws_instance" "bastion" {
  instance_id = module.network.bastion_instance_id
}

resource "aws_security_group" "bastion" {
  name   = "bastion_ssh_new"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "bastion" {
  security_group_id = aws_security_group.bastion.id
  network_interface_id = data.aws_instance.bastion.network_interface_id
}
