# TODO: make this a properly configured bastion host 
resource "aws_instance" "bastion_host" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"

  instance_type = "${var.INSTANCE_TYPE}"

  key_name = "${aws_key_pair.ec2_key.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bastion-host-sg.id}"]

  subnet_id = "${aws_subnet.public-subnet-1.id}"

  source_dest_check = "false"

  tags {
    Name = "bastion_host"
  }
}
