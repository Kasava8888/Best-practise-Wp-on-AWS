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
    vpc_id = module.vpc.vpc_idm
    subnet_idm = module.vpc.pub_sub_az1_id

}