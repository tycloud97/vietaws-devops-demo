
resource "aws_security_group" "allow_80" {
  name        = "${var.environment_name}_allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = module.custom_vpc.vpc_id

  ingress = [
    {
      description      = "HTTP port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outgoing all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    }
  ]

  tags = {
    Name        = "allow_80"
    ProjectName = var.environment_name
  }
}

resource "aws_security_group" "allow_443" {
  name        = "${var.environment_name}_allow_https"
  description = "Allow https inbound traffic"
  vpc_id      = module.custom_vpc.vpc_id

  ingress = [
    {
      description      = "HTTP port"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outgoing all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name        = "allow_443"
    ProjectName = var.environment_name
  }
}

resource "aws_security_group" "allow_8080" {
  name        = "${var.environment_name}_Wildfly_8080"
  description = "Allow 8080 inbound traffic"
  vpc_id      = module.custom_vpc.vpc_id

  tags = {
    Name        = "allow_8080",
    ProjectName = var.environment_name
  }
}

resource "aws_security_group_rule" "allow-8080-from-80-ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_8080.id
  source_security_group_id = aws_security_group.allow_80.id
}

resource "aws_security_group_rule" "allow-8080-from-443-ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_8080.id
  source_security_group_id = aws_security_group.allow_443.id
}

resource "aws_security_group_rule" "allow-8080-to-80-egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_8080.id
  source_security_group_id = aws_security_group.allow_80.id
}

resource "aws_security_group_rule" "allow-8080-to-443-egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_8080.id
  source_security_group_id = aws_security_group.allow_443.id
}

resource "aws_security_group_rule" "allow-8080-to-2049-egress" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_8080.id
  source_security_group_id = aws_security_group.allow_nfs.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.environment_name}_SSH"
  description = "Allow SSH inbound traffic inside vpc"
  vpc_id      = module.custom_vpc.vpc_id

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outgoing to ALB sg"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  tags = {
    Name        = "${var.environment_name}_allow_ssh_from_vpc",
    ProjectName = var.environment_name
  }
}

resource "aws_security_group" "allow_nfs" {
  name        = "${var.environment_name}_NFS"
  description = "Allow NFS inbound traffic inside vpc"
  vpc_id      = module.custom_vpc.vpc_id

  tags = {
    Name        = "${var.environment_name}_allow_nfs_from_vpc",
    ProjectName = var.environment_name
  }
}

resource "aws_security_group_rule" "allow-2049-from-8080-ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_nfs.id
  source_security_group_id = aws_security_group.allow_8080.id
}

resource "aws_security_group_rule" "allow-2049-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.allow_nfs.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group" "http" {
  vpc_id = module.custom_vpc.vpc_id

  name        = "${var.environment_name}-allow-http"
  description = "Allow all http inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = module.custom_vpc.vpc_id

  name        = "${var.environment_name}-allow-ssh"
  description = "Allow ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_outbound" {
  vpc_id = module.custom_vpc.vpc_id

  name        = "${var.environment_name}-allow-all-outbound"
  description = "Allow outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}