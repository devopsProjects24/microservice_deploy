# Instances in public subnets
resource "aws_instance" "sonarqube" {
  count           = 1
  instance_type   = "t2.medium"
  ami             = "ami-0c7217cdde317cfec"
  key_name        = "practice"
  user_data = file("${path.module}/sonarqube.sh")
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.sonarqube_vpc_security_group.id]

  tags = {
    Name = "sonarqube-${count.index}"
  }
}
# security group for instances in public subnets
resource "aws_security_group" "sonarqube_vpc_security_group" {
  vpc_id = aws_vpc.cloudinfra_vpc.id

 ingress { #http
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #http
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #https
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #tcp
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #http
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonarqube_vpc_security_group"
  }
}
