output "sg_id" {
  value = aws_security_group.wp-sg.id
}
output "ami_wp" {
  value = data.aws_ami.wp.id
  
}
output "wp_sg" {
  value = aws_security_group.wp-sg.id
  
}
output "wp_1_id" {
  value = aws_instance.wp_1.id
  
}
output "wp_2_id" {
  value = aws_instance.wp_2.id
  
}
output "wp_2" {
  value = aws_instance.wp_2
  
}
output "wp_1" {
  value = aws_instance.wp_1
  
}
output "alb_security_group" {
  value = aws_security_group.alb_security_group.id
  
}