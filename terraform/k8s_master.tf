data "aws_key_pair" "your_key" {
  key_name           = "project_key" # Provide Your own key_name in us-east-1 Region
  include_public_key = true
}

locals {
  chosen_subnet_index = 0 # You can change this index if you want to choose a different subnet
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

resource "aws_launch_template" "k8s_master" {
  name            = "k8s_master_tpl"
  image_id        = "ami-0cd59ecaf368e5ccf"
  instance_type   = "t2.medium"
  key_name        = data.aws_key_pair.your_key.key_name
  user_data       = filebase64("${path.module}/user_data/k8s-master.sh")

  network_interfaces {
    subnet_id       = aws_subnet.public_subnets[local.chosen_subnet_index].id
    security_groups = [aws_security_group.k8s_master_security_group.id, aws_security_group.worker_to_master_security_group.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s_master"
    }
  }

  tags = {
    Name = "k8s-master_tpl"
  }

}

resource "aws_autoscaling_group" "k8s_master" {

  name             = "k8s_master_asg"
  max_size         = 4
  min_size         = 1
  desired_capacity = 1

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id = aws_launch_template.k8s_master.id
  }
}

# scale up policy
resource "aws_autoscaling_policy" "master_scale_up" {
  name                   = "k8s_master_asg_scale_up"
  autoscaling_group_name = aws_autoscaling_group.k8s_master.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "master_scale_up_alarm" {
  alarm_name          = "k8s_master_asg_scale_up_alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80" # New instance will be created once CPU utilization is higher than 30 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.k8s_master.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.master_scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "master_scale_down" {
  name                   = "k8s_master_asg_scale_down"
  autoscaling_group_name = aws_autoscaling_group.k8s_master.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "master_scale_down_alarm" {
  alarm_name          = "k8s_master_asg_scale_down_alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.k8s_master.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.master_scale_down.arn]
}