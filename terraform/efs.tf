# EFS Configuration
resource "aws_efs_file_system" "sls_efs" {
  creation_token = "sls_efs"
  encrypted      = true

  tags = {
    Name = "sls_efs"
  }
}

resource "aws_efs_mount_target" "sls_efs_mount_targets" {
  count           = 1
  file_system_id  = aws_efs_file_system.sls_efs.id
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