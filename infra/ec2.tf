provider "aws" {
  region = "ap-south-1"
}


resource "aws_security_group" "nodejs_sg" {
  name        = "nodejs-sg"
  description = "Allow SSH and app port"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_instance" "nodejs_server" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  key_name      = "chatgpt"
  security_groups = [aws_security_group.nodejs_sg.name]

  tags = {
    Name = "nodejs-server"
  }
}

output "public_ip" {
  value = aws_instance.nodejs_server.public_ip
}
