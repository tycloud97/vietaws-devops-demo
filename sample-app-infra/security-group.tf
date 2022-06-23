
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