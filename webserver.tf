# 1 EC2
variable "webserver_list" {
  type = list(string)
  default = [ "web01", "web02" ]
  
}

resource "aws_instance" "sample-ec2-web01" {
  ami                     = "ami-0f9816f78187c68fb"
  instance_type           = "t2.micro"
  key_name                = "iac-key"
  subnet_id = aws_subnet.sample-subnet-private01.id
  associate_public_ip_address = false
  security_groups = [data.aws_security_group.default-sg.id]
  tags = {
    Name = "sample-ec2-web01"
  }
}

resource "aws_instance" "sample-ec2-web02" {
  ami                     = "ami-0f9816f78187c68fb"
  instance_type           = "t2.micro"
  key_name                = "iac-key"
  subnet_id = aws_subnet.sample-subnet-private02.id
  associate_public_ip_address = false
  security_groups = [data.aws_security_group.default-sg.id]
  tags = {
    Name = "sample-ec2-web02"
  }
}