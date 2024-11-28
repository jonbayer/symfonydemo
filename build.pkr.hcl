# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu-lts" {
  region = "us-east-1"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

  ami_name    = "symfonydemo_{{timestamp}}"
  ami_regions = ["us-east-1"]
}

build {
  # HCP Packer settings
  hcp_packer_registry {
    bucket_name = "webstack"
    description = <<EOT
This is an image for HashiCups.
    EOT

    bucket_labels = {
      "role" = "nginx_composer_webserver",
    }
  }

  sources = [
    "source.amazon-ebs.ubuntu-lts",
  ]


  # Set up HashiCups

  provisioner "shell" {
    inline = [
      "/usr/bin/cloud-init status --wait"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update && sudo apt-get -y upgrade  && sudo apt-get -y install nginx && sudo chown -R ubuntu: /var/www/html && sudo add-apt-repository ppa:ondrej/php"
    ]
  }
  provisioner "file" {
    source      = "./"
    destination = "/var/www/html/"
  }
   provisioner "ansible" {
      playbook_file = "./ansible/webserver.yml"
#  extra_arguments = [ "-vvvv" ]  
  }

  # systemd unit for HashiCups service

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      version_fingerprint = packer.versionFingerprint
    }
  }
}
