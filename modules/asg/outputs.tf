output "lb_ip"{
  value = aws_lb.app_lb.dns_name
}
