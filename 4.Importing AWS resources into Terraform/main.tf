import {
  to = aws_instance.server
  identity = {
    id = "i-01e3a6e0e9a052ca9"
  }
}

resource "aws_instance" "server" {
  ami           = "ami-08e3b3155fc937a94"
  instance_type = "t3.micro"
  ### Configuration omitted for brevity ###
  tags = {
    "Name" = "EC2-B"
  }
  tags_all = {
    "Name" = "EC2-B"
  }
}
