data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com"
}
resource "aws_security_group" "sg_bastion" {
  vpc_id = var.vpc_id
  name = "sg_bastion"
  description = "bastion-host"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
}

resource "aws_instance" "bastion" {
  ami                           = data.aws_ami.amazon_linux_2.id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  subnet_id                     = var.pub_sub_az1_id
  key_name                      = "tgw"
  vpc_security_group_ids        = [ aws_security_group.sg_bastion.id ]

  tags = {
    Name = "${var.project_name}-basion-host"
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "asg"
  max_size = 3
  min_size = 1
  desired_capacity = 2
  depends_on = [ var.load_balancers, var.target_group  ]
  target_group_arns = [var.target_group]
  health_check_type = "ELB"
  launch_template {
    id = aws_launch_template.template.id
    version = "$Latest"
  }
  vpc_zone_identifier = ["${var.pri_sub_az1_id}", "${var.pri_sub_az2_id}" ]

  tag {
    key = "Name"
    value = "${var.project_name}-autoscaling-groups"
    propagate_at_launch = true
  }
}


resource "aws_launch_template" "template" {
  name_prefix = "${var.project_name}-template"
  image_id = var.ami_wordpress
  key_name = "tgw"
  instance_type = "t2.micro"
  vpc_security_group_ids = []
}