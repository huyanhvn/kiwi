resource "aws_iam_role_policy" "kiwi" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-asg-policy"
  role = "${aws_iam_role.kiwi.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:AttachVolume",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:CreateKeypair",
          "ec2:DeleteKeypair",
          "ec2:DescribeSubnets",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateImage",
          "ec2:CopyImage",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:DescribeInstances",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:RegisterImage",
          "ec2:DeregisterImage",
          "ec2:CreateTags",
          "ec2:ModifyImageAttribute"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*"
      ],
      "Resource": "*"
    },
    {
      "Resource": "arn:aws:logs:*:*:log-group:*",
      "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
      ],
      "Effect": "Allow"
    }
  ]
} 
EOF
}

resource "aws_iam_instance_profile" "kiwi" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-asg-profile"
  roles = ["${aws_iam_role.kiwi.name}"]
}

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

resource "aws_security_group" "kiwi" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-asg-sg"
  description = "Allow traffic in"
  vpc_id = "${var.vpc_id}"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ "${var.ssh_ingress}" ]
  }
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      security_groups = [ "${var.lb_sg_id}" ]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "kiwi" {
  image_id                  = "${data.aws_ami.ubuntu.id}"
  instance_type             = "t2.small"
  iam_instance_profile      = "${aws_iam_instance_profile.kiwi.name}" 
  key_name                  = "${var.ssh_key_name}"
  security_groups           = ["${aws_security_group.kiwi.id}"]
  user_data                 = "${file("modules/asg/userdata.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kiwi" {
  name                      = "kiwi"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.kiwi.name}"
  vpc_zone_identifier       = "${var.subnets}"
  target_group_arns         = "${var.target_group_arns}"

  tag {
    key = "Name"
    value = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-kiwi"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}


resource "aws_iam_role" "kiwi" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-asg-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}


#### Outputs
output "kiwi_asg_id" {
  value = "${aws_autoscaling_group.kiwi.id}"
}

output "kiwi_sg_id" {
  value = "${aws_security_group.kiwi.id}"
}