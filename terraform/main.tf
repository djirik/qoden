provider "aws" {
    region = "${var.aws_region}"
    shared_credentials_file = "../.creds"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}


resource "aws_subnet" "qoden" {
  vpc_id            = "${data.aws_vpc.main.id}"
  availability_zone = "eu-north-1c"
  cidr_block = "${cidrsubnet(data.aws_vpc.main.cidr_block, 4, 1)}"
}


resource "aws_security_group" "allow_http_ssh" {
  name = "allow_http_ssh"
  vpc_id = "${data.aws_vpc.main.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_network_interface" "qoden_net" {
  subnet_id = "${aws_subnet.qoden.id}"
  security_groups = ["${aws_security_group.allow_http_ssh.id}"]
}

resource "aws_network_interface" "qoden_net1" {
  subnet_id = "${aws_subnet.qoden.id}"
  security_groups = ["${aws_security_group.allow_http_ssh.id}"]
}

resource "aws_key_pair" "qoden" {
  key_name = "${var.key_name}"
  public_key = "${var.public_key_path}"
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.micro"
  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.qoden_net.id}"
  }
  key_name = "${var.key_name}"
  tags = {
    Name = "application"
  }

}

resource "aws_instance" "db" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.micro"
  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.qoden_net1.id}"
  }
  key_name = "${var.key_name}"
  tags = {
    Name = "db"
  }
}

resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

resource "aws_eip" "db" {
  instance = "${aws_instance.db.id}"
  vpc      = true
}


resource "null_resource" "init" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python"
    ]
    connection {
        type     = "ssh"
        user     = "ubuntu"
        agent = false
        host = "${aws_eip.db.public_ip}"
        private_key = file("../ssh-keys/qoden")
    }
  }    
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python"
    ]
    connection {
        type     = "ssh"
        user     = "ubuntu"
        agent = false
        host = "${aws_eip.web.public_ip}"
        private_key = file("../ssh-keys/qoden")
    }
  }

  provisioner "local-exec" {
    command = <<EOF
    echo [web] > ../ansible/hosts
    echo "app ansible_host=${aws_eip.web.public_ip} ansible_port=22 ansible_user=ubuntu" >> ../ansible/hosts
    echo [db] >> ../ansible/hosts
    echo "postgres ansible_host=${aws_eip.db.public_ip} ansible_port=22 ansible_user=ubuntu" >> ../ansible/hosts
    EOF
  }
}
