data "aws_ami" "wp" {
    owners = ["self"]
    filter {
        name = "name"
        values = ["wordpress"]
    }
}


resource "aws_security_group" "ec2iec" {
  name        = "ec2iec"
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
    cidr_blocks = ["0.0.0.0/0"]
    security_groups =  [aws_security_group.ec2iec.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}

  

resource "aws_instance" "wp" {
    ami = data.aws_ami.wp.id
    instance_type = "t2.micro"
    associate_public_ip_address = true
    security_groups = [aws_security_group.wp-sg.id]
    key_name = "tgw"
    subnet_id = var.subnet_idm
    
  #   root_block_device {
  #       volume_type = "gp2"
  #       volume_size = 8
  # }
    
    tags = {
        Name = "wordpress"       
  }
  
}
resource "aws_ec2_instance_connect_endpoint" "ec2ice" {
  subnet_id = var.subnet_idm
  
}