data "aws_key_pair" "your_key" {
  key_name           = "project_key" # Provide Your own key_name in us-east-1 Region
  include_public_key = true
}

resource "aws_instance" "k8s-master" {
  count           = 1
  instance_type   = "t2.medium"
  ami             = "ami-0cd59ecaf368e5ccf"
  key_name        = data.aws_key_pair.your_key.key_name
  user_data       = file("${path.module}/user_data/k8s-master.sh")
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.k8s_master_security_group.id, aws_security_group.worker_to_master_security_group.id]

  tags = {
    Name = "k8s-master"
  }
}

locals {
  chosen_subnet_index = 0 # You can change this index if you want to choose a different subnet
}

resource "aws_instance" "k8s-worker" {
  count           = 2
  instance_type   = "t2.medium"
  ami             = "ami-0cd59ecaf368e5ccf"
  key_name        = data.aws_key_pair.your_key.key_name
  user_data       = file("${path.module}/user_data/k8s-worker.sh")
  subnet_id       = aws_subnet.public_subnets[local.chosen_subnet_index].id
  security_groups = [aws_security_group.k8s_worker_security_group.id]

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}

resource "aws_security_group" "k8s_master_security_group" {
  vpc_id = aws_vpc.cloudinfra_vpc.id
  name   = "k8s_master_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6784
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10248
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9099
    to_port     = 9099
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 179
    to_port     = 179
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
    Name = "k8s_master_security_group"
  }
}

resource "aws_security_group" "k8s_worker_security_group" {
  vpc_id = aws_vpc.cloudinfra_vpc.id
  name   = "k8s_worker_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6784
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10248
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9099
    to_port     = 9099
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.k8s_master_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_worker_security_group"
  }
}

resource "aws_security_group" "worker_to_master_security_group" {
  vpc_id = aws_vpc.cloudinfra_vpc.id
  name   = "worker_to_master_security_group"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.k8s_worker_security_group.id]
  }

  tags = {
    Name = "worker_to_master_security_group"
  }
}

# EFS Configuration
resource "aws_efs_file_system" "k8s_worker_efs" {
  creation_token = "k8s_worker_efs"
  encrypted      = true

  tags = {
    Name = "k8s_worker_efs"
  }
}

resource "aws_efs_mount_target" "k8s_worker_efs_mount_targets" {
  count           = 1
  file_system_id  = aws_efs_file_system.k8s_worker_efs.id
  subnet_id       = aws_subnet.public_subnets[local.chosen_subnet_index].id
  security_groups = [aws_security_group.k8s_master_security_group.id, aws_security_group.k8s_worker_security_group.id]
}

resource "aws_efs_file_system" "sts_efs" {
  creation_token = "sts_efs"
  encrypted      = true

  tags = {
    Name = "sts_efs"
  }
}

resource "aws_efs_mount_target" "sts_efs_mount_targets" {
  count           = 1
  file_system_id  = aws_efs_file_system.sts_efs.id
  subnet_id       = aws_subnet.public_subnets[local.chosen_subnet_index].id
  security_groups = [aws_security_group.k8s_master_security_group.id, aws_security_group.k8s_worker_security_group.id]
}