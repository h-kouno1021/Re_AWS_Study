output "lb_arn" {
  value = aws_lb.front_end.arn
}

output "lb_security_group_id" {
  value = aws_security_group.alb.id
}
