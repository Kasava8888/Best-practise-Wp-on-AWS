resource "aws_security_group" "sg_rds" {
    name = "sg_rds"
    description = "Allow port 3306 My SQL"
    vpc_id = var.vpc_id
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = [ var.wp_sg ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg_rds"
  }
}

data "aws_rds_engine_version" "rds_engine_version" {
  engine = "mysql"
  version = "8.0.35"
}

data "aws_availability_zones" "aws_availability_zones" {
  state = "available"
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "${var.project_name}subnet-group"
  subnet_ids = [var.pri_data_sub_az1_id, var.pri_data_sub_az2_id]
  tags = {
    Name = "${var.project_name}-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage           = 30
  auto_minor_version_upgrade  = false                         
  backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  engine                      = data.aws_rds_engine_version.rds_engine_version.engine
  engine_version              = data.aws_rds_engine_version.rds_engine_version.version
  identifier                  = "db-master"
  instance_class              = "db.t3.micro"
  multi_az                    = false 
  password                    = var.password
  username                    = "haidang"
  storage_encrypted           = true
  skip_final_snapshot  = true

  tags = {
    Name = "${var.project_name}-master-rds"
  }

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}




resource "aws_db_instance" "read-replica" {
  replicate_source_db         = aws_db_instance.rds.identifier
  auto_minor_version_upgrade  = false
  backup_retention_period     = 7
  identifier                  = "read-replica"
  instance_class              = "db.t3.micro"
  multi_az                    = false 
  skip_final_snapshot         = true
  storage_encrypted           = true
  vpc_security_group_ids = [ aws_security_group.sg_rds.id ]

  tags = {
    Name = "${var.project_name}-read-replica"
  }

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}