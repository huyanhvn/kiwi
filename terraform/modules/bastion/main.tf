data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "bastion" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-bastion-sg"
  description = "Allow traffic into bastion"
  vpc_id = var.vpc_id
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ var.ssh_ingress ]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = "t2.small"
  key_name                  = var.ssh_key_name
  vpc_security_group_ids    = [ aws_security_group.bastion.id ]
  user_data                 = "${file("modules/bastion/userdata.sh")}"
  subnet_id                 = var.subnet_id
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
