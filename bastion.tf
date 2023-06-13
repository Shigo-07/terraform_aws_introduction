# 1 EC2

resource "aws_instance" "sample-ec2-bastion" {
  ami                     = "ami-0f9816f78187c68fb"
  instance_type           = "t2.micro"
  key_name                = "iac-key"
  subnet_id = aws_subnet.sample-subnet-public01.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sample-sg-bastion.id,data.aws_security_group.default-sg.id]
  tags = {
    Name = "sample-ec2-bastion"
  }
}