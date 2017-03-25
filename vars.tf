variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "AMIS" {
  type = "map"

  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-95f8d2f3"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "ec2_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "ec2_key.pub"
}

variable "INSTANCE_USERNAME" {
  default = ""
}

variable "AWS_PROFILE" {
  default = "terraform"
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}
