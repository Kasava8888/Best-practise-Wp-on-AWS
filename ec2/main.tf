resource "aws_security_group" "alb_security_group" {
  vpc_id = var.vpc_id
  description = "allow http"
  name = "alb security groups"

  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "tcp"
  }
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = -1
  }
}
data "aws_ami" "wp" {
    owners = ["self"]
    filter {
        name = "name"
        values = ["wordpress"]
    }
}

resource "aws_security_group" "ec2ice" {
  name        = "ec2ice"
  description = "ec2 endpoint"
  vpc_id      = var.vpc_id
  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_security_group" "wp-sg" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups =  [ aws_security_group.ec2ice.id, var.sg_bastion ]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [ aws_security_group.alb_security_group.id ]
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    security_groups = [ aws_security_group.alb_security_group.id ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-wp-sg"
  }
}

  

resource "aws_instance" "wp_1" {
    ami = data.aws_ami.wp.id
    instance_type = "t2.micro"
    associate_public_ip_address = false
    vpc_security_group_ids = [aws_security_group.wp-sg.id]
    key_name = "tgw"
    subnet_id = var.subnet_id_1
    
  #   root_block_device {
  #       volume_type = "gp2"
  #       volume_size = 8
  # }
    
    tags = {
        Name = "wordpress_1"       
  }
  
}

resource "aws_instance" "wp_2" {
    ami = data.aws_ami.wp.id
    instance_type = "t2.micro"
    associate_public_ip_address = false
    vpc_security_group_ids = [aws_security_group.wp-sg.id]
    key_name = "tgw"
    subnet_id = var.subnet_id_2
    
  #   root_block_device {
  #       volume_type = "gp2"
  #       volume_size = 8
  # }
    
    tags = {
        Name = "wordpress_2"       
  }
  
}
 resource "aws_ec2_instance_connect_endpoint" "ec2ice" {
   subnet_id = var.subnet_id_1
   security_group_ids = [aws_security_group.ec2ice.id]
 }