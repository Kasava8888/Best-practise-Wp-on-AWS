module "vpc" {
    source = "../modules/vpc"
    cidr_block = var.cidr_block
    project_name = var.project_name
    cidr_pub_sub_az2 = var.cidr_pub_sub_az2
    cidr_pub_sub_az1 = var.cidr_pub_sub_az1
    cidr_pri_sub_az1 = var.cidr_pri_sub_az1
    cidr_pri_sub_az2 = var.cidr_pri_sub_az2
    cidr_pri_data_sub_az1 = var.cidr_pri_data_sub_az1
    cidr_pri_data_sub_az2 = var.cidr_pri_data_sub_az2
}

module "ec2" {
    source = "../modules/ec2"
    vpc_id = module.vpc.vpc_id
    subnet_id_1 = module.vpc.pri_sub_az1_id
    subnet_id_2 = module.vpc.pri_sub_az2_id
    sg_bastion = module.asg.sg_bastion
    project_name = var.project_name
    
}
module "alb" {
    source = "../modules/alb"
    project_name = var.project_name
    vpc_id = module.vpc.vpc_id
    pub_sub_az1_id = module.vpc.pub_sub_az1_id
    pub_sub_az2_id = module.vpc.pub_sub_az2_id
    wp_1_id = module.ec2.wp_1_id
    wp_2_id = module.ec2.wp_2_id
    wp_1 = module.ec2.wp_1
    wp_2 = module.ec2.wp_2
    alb_security_group = module.ec2.alb_security_group
}
module "asg" {
    source = "../modules/asg"
    load_balancers = module.alb.load_balancers
    target_group = module.alb.target_group_arn
    ami_wordpress = module.ec2.ami_wp
    project_name = var.project_name
    pri_sub_az1_id = module.vpc.pri_sub_az1_id
    pri_sub_az2_id = module.vpc.pri_sub_az2_id
    pub_sub_az1_id = module.vpc.pub_sub_az1_id
    vpc_id = module.vpc.vpc_id
}
module "efs" {
    source = "../modules/efs"
    vpc_id = module.vpc.vpc_id
    wp_sg = module.ec2.wp_sg
    project_name = var.project_name
    pri_data_sub_az2_id = module.vpc.pri_data_sub_az2_id
    pri_data_sub_az1_id = module.vpc.pri_data_sub_az1_id
  
}
module "s3" {
    source = "../modules/s3"
    project_name = var.project_name
}
module "rds" {
    source = "../modules/rds"
    project_name = var.project_name
    vpc_id = module.vpc.vpc_id
    wp_sg = module.ec2.wp_sg
    pri_data_sub_az1_id = module.vpc.pri_data_sub_az1_id
    pri_data_sub_az2_id = module.vpc.pri_data_sub_az2_id
    password = var.password
  
}
module "elasticache" {
    source = "../modules/elasticache"
    pri_data_sub_az1_id = module.vpc.pri_data_sub_az1_id
    pri_data_sub_az2_id = module.vpc.pri_data_sub_az2_id
    project_name = var.project_name
    vpc_id = module.vpc.vpc_id
    wp_sg = module.ec2.wp_sg
  
}
# module "instance" {
#   source = "cloudposse/ec2-instance/aws"
#   # Cloud Posse recommends pinning every module to a specific version
#   # version     = "x.x.x"
#   #ssh_key_pair                = var.ssh_key_pair
#   instance_type               = "t2.micro"
#   vpc_id                      = module.vpc.vpc_id
#   security_groups             = [module.ec2.sg_id]
#   subnet                      = module.vpc.pub_sub_az1_id
#   name                        = "ec2"
#   #namespace                   = "eg"
#   #stage                       = "dev"
# }