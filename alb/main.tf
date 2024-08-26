#create application load banlancer
# resource "aws_security_group" "alb_security_group" {
#   vpc_id = var.vpc_id
#   description = "allow http"
#   name = "alb security groups"

#   ingress {
#     from_port = 80
#     to_port = 80
#     cidr_blocks = [ "0.0.0.0/0" ]
#     protocol = "tcp"
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     cidr_blocks = [ "0.0.0.0/0" ]
#     protocol = -1
#   }
# }

resource "aws_alb" "my_alb" {
  name = "${var.project_name}-my-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [ var.alb_security_group ]
  subnets = [var.pub_sub_az1_id, var.pub_sub_az2_id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-my-alb"
  }
}

#create tagert group

resource "aws_alb_target_group" "my_alb_tg" {
    name = "${var.project_name}-tg"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
      enabled = true
      interval = 300
      path = "/"
      timeout = 60
      matcher = 200
      healthy_threshold = 5
      unhealthy_threshold = 5
    }

    lifecycle {
      create_before_destroy = true
    }
}
resource "aws_lb_target_group_attachment" "tg-attachment1" {
  target_group_arn = "${aws_alb_target_group.my_alb_tg.arn}"
  target_id        = "${var.wp_1_id}"
  port             = 80
  depends_on = [ var.wp_1 ]
}
resource "aws_lb_target_group_attachment" "tg-attachment2" {
  target_group_arn = "${aws_alb_target_group.my_alb_tg.arn}"
  target_id        = "${var.wp_2_id}"
  port             = 80
  depends_on = [ var.wp_2 ]
}
#create a listener on port 80 with redirect action

resource "aws_alb_listener" "my_alb_http_listener" {
  load_balancer_arn = aws_alb.my_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.my_alb_tg.arn
  }
}



