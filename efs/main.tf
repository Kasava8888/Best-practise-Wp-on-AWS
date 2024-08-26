resource "aws_security_group" "sg_efs" {
    name = "sg_efs"
    description = "Allow port 2049 efs"
    vpc_id = var.vpc_id
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    security_groups = [ var.wp_sg ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-efs"
  }
}


resource "aws_efs_file_system" "efs" {
  encrypted = false
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

# Tạo Mount Target cho Subnet 1
resource "aws_efs_mount_target" "mount_target_az1" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.pri_data_sub_az1_id
  security_groups = [ aws_security_group.sg_efs.id ]  
}

# Tạo Mount Target cho Subnet 2
resource "aws_efs_mount_target" "mount_target_2" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.pri_data_sub_az2_id
  security_groups = [ aws_security_group.sg_efs.id ]  
}