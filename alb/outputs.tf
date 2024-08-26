output "target_group_arn" {
  value = aws_alb_target_group.my_alb_tg.arn
}
output "load_balancers" {
  value = aws_alb.my_alb
  
}
output "target_group" {
  value = aws_alb_target_group.my_alb_tg
  
}
