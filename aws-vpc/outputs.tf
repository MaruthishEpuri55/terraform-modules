output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_with_nat_subnet_id" {
  value = aws_subnet.private_with_nat.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "security_group_id" {
  value = aws_security_group.ssh.id
}
