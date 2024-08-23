output "vpc_idm" {
    value = aws_vpc.myvpc.id
}
output "pub_sub_az1_id" {
    value = aws_subnet.pub_sub_az1.id
  
}