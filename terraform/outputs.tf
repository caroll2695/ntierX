output "natIP" {
  value = aws_instance.nat.public_ip
}

output "appservers" {
  value = join(",", aws_instance.app.*.private_ip)
}

output "elbHostname" {
  value = aws_elb.app.dns_name
}

