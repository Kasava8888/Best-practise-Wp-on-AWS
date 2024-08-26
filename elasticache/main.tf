resource "aws_security_group" "sg_elasticache" {
  name        = "sg_elasticache"
  description = "Security group for Elasticache"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    security_groups = [ var.wp_sg ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-elasticache"
  }
}
resource "aws_elasticache_subnet_group" "memcached_subnet_group" {
  name       = "memcached-subnet-group"
  subnet_ids = [var.pri_data_sub_az1_id, var.pri_data_sub_az2_id]

  tags = {
    Name = "${var.project_name}-memcached-subnet-group"
  }
}

resource "aws_elasticache_cluster" "memcached_cluster" {
  cluster_id           = "memcached-cluster"
  engine               = "memcached"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2  
  parameter_group_name = "default.memcached1.6"

  subnet_group_name    = aws_elasticache_subnet_group.memcached_subnet_group.name
  security_group_ids   = [aws_security_group.sg_elasticache.id]

  tags = {
    Name = "${var.project_name}-memcached-cluster"
  }
}