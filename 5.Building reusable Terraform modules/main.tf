module "ec2_instance" {
  source        = "./module/ec2"
  instance_type = "t2.micro"
  image_os      = "ubuntu"
  tagging = {
    "name"         = "ashelga-instance"
    "BusinessUnit" = "Cybersecurity"
  }
}
