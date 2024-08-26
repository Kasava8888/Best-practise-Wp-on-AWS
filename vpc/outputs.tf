output "vpc_id" {
    value = aws_vpc.myvpc.id
}
output "pri_sub_az1_id" {
    value = aws_subnet.pri_sub_az1.id
  
}
output "pri_sub_az2_id" {
    value = aws_subnet.pri_sub_az2.id
  
}
output "pri_data_sub_az1_id" {
    value = aws_subnet.pri_data_sub_az1.id
  
}
output "pri_data_sub_az2_id" {
    value = aws_subnet.pri_data_sub_az2.id
  
}
output "pub_sub_az1_id" {
    value = aws_subnet.pub_sub_az1.id
  
}
output "pub_sub_az2_id" {
    value = aws_subnet.pub_sub_az2.id
  
}