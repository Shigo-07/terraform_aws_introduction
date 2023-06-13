# default sg
# how to filter https://registry.terraform.io/providers/hashicorp/aws/3.74.1/docs/data-sources/security_groups
data "aws_security_group" "default-sg" {
  vpc_id = aws_vpc.sample-vpc.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}