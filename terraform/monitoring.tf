# Create an EC2 instance for monitoring with an attached EBS volume
resource "aws_instance" "Monitoring" {
  count           = 1
  instance_type   = "t2.medium"
  ami             = "ami-06aa3f7caf3a30282"
  key_name        = "project_key" # Provide Your own key_name in us-east-1 Region
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [aws_security_group.monitoring_security_group.id]

  # Define EBS block device mapping for the instance
  root_block_device {
    volume_type           = "gp2"  # General Purpose SSD (default)
    volume_size           = 20     # Size in gigabytes
    delete_on_termination = true   # Automatically delete volume when instance is terminated
  }
  tags = {
    Name = "Monitoring"
  }
}

# Security group for instances in public subnets
resource "aws_security_group" "monitoring_security_group" {
  vpc_id = aws_vpc.cloudinfra_vpc.id

    ingress { # HTTP
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Prometheus
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Node-Exporter
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Grafana
    from_port   = 3000
    to_port     = 3000
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
    Name = "monitoring_security_group"
  }
}
