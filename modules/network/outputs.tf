

output "vpc_id" {

  description = "ID of the VPC created"

  value = aws_vpc.main.id
}

output "vpc_cidr" {

  description = "CIDR block for VPC"

  value = aws_vpc.main.cidr_block

}

output "public_subnet_1a_id" {

  description = "ID of the public subnet in AZ 1a"
  value       = aws_subnet.public_subnet_1a.id
}

output "public_subnet_1b_id" {
  description = "ID of the public subnet in AZ 1b"
  value       = aws_subnet.public_subnet_1b.id
}

output "private_subnet_1a_id" {
  description = "ID of the private subnet in AZ 1a"
  value       = aws_subnet.private_subnet_1a.id
}

output "private_subnet_1b_id" {
  description = "ID of the private subnet in AZ 1b"
  value       = aws_subnet.private_subnet_1b.id
}
