packer {
  required_plugins {
    amazon = {
      version = ">=0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "ubuntu-packer-ami"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-southeast-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-*-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    Name          = "${var.ami_prefix}-${local.timestamp}"
    Release       = "Latest"
    Base_AMI_ID   = "{{.SourceAMI}}"
    Base_AMI_Name = "{{.SourceAMIName}}"
    Owner         = "cherrera"
  }
  run_tags = {
    Name          = "Packer Builder EC2"
    Base_AMI_ID   = "{{.SourceAMI}}"
    Base_AMI_Name = "{{.SourceAMIName}}"

  }
}

build {
  name = "an-ubuntu-image"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing nginx, redis",
      "sleep 10",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring",
      "sudo curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null",
      "sudo echo \"deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx\" | sudo tee /etc/apt/sources.list.d/nginx.list",
      "sudo echo -e \"Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n\" | sudo tee /etc/apt/preferences.d/99nginx ",
      "sudo apt-get install -y nginx redis-server",
    ]
  }

  post-processor "vagrant" {}

}
