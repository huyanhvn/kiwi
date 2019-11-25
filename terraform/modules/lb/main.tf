resource "aws_security_group" "lb" {
  name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-lb-sg"
  description = "Allow traffic in to ELB"
  vpc_id = "${var.vpc_id}"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [ "${var.lb_ingress}" ]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [ "${var.lb_ingress}" ]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "http" {
  name        = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-tg-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_lb_target_group" "https" {
  name        = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-tg-https"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_lb" "kiwi" {
  name               = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = "${var.subnets}"
  security_groups    = ["${aws_security_group.lb.id}"]

  access_logs {
    bucket           = "${var.s3_bucket}"
    prefix           = "kiwi-lb"
    enabled          = true
  }
  tags = {
    Name = "${var.tags["Environment"]}-${var.aws_region}-${var.tags["AppName"]}-kiwi-lb"
    Environment = "${var.tags["Environment"]}"
    CreatedBy = "${var.tags["CreatedBy"]}"
    AppName = "${var.tags["AppName"]}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.kiwi.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.http.arn}"
  }
}


# Outputs
output "lb_sg_id" {
  value = "${aws_security_group.lb.id}"
}

output "http_target_group_arn" {
  value = "${aws_lb_target_group.http.arn}"
}

output "https_target_group_arn" {
  value = "${aws_lb_target_group.https.arn}"
}