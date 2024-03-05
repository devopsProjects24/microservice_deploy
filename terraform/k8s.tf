# Instances in public subnets for k8s-master
resource "aws_instance" "k8s-master" {
  count           = 1
  instance_type   = "t2.medium"
  ami             = "ami-0440d3b780d96b29d"
  key_name        = "practice"
  user_data = file("${path.module}/k8s-master.sh")
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.k8s_security_group.id]

  tags = {
    Name = "k8s-master-${count.index}"
  }
}
# Instances in public subnets for k8s-worker
resource "aws_instance" "k8s-worker" {
  count           = 1
  instance_type   = "t2.medium"
  ami             = "ami-0440d3b780d96b29d"
  key_name        = "practice"
  user_data = file("${path.module}/k8s-worker.sh")
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.k8s_security_group.id]

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
# security group for instances in public subnets
resource "aws_security_group" "k8s_security_group" {
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
  ingress { # Kubernetes API server
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # etcd server
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # etcd server
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # kubelet API
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # kube-scheduler
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # kube-controller
    from_port   = 10257
    to_port     = 10257
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
    Name = "k8s_security_group"
  }
}
