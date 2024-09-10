# data "aws_availability_zones" "available" {}

# resource "aws_vpc" "my_vpc" {
#   cidr_block = "10.0.0.0/16"  # CIDR block for the VPC
#   enable_dns_support = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "my-vpc"
#   }
# }

# resource "aws_subnet" "my_subnet" {
#   count = 2  # Create two subnets as an example

#   vpc_id     = aws_vpc.my_vpc.id
#   cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
#   availability_zone = element(data.aws_availability_zones.available.names, count.index)
#   map_public_ip_on_launch = true  # Optional: For public subnets
#   tags = {
#     Name = "my-subnet-${count.index}"
#   }
# }

# resource "aws_internet_gateway" "my_igw" {
#   vpc_id = aws_vpc.my_vpc.id
#   tags = {
#     Name = "my-igw"
#   }
# }

# resource "aws_route_table" "my_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }

#   tags = {
#     Name = "my-route-table"
#   }
# }

# resource "aws_route_table_association" "my_route_table_association" {
#   count          = 2
#   subnet_id      = element(aws_subnet.my_subnet[*].id, count.index)
#   route_table_id = aws_route_table.my_route_table.id
# }