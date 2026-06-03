resource "aws_instance" "web" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  subnet_id                   = aws_subnet.publicSubnet1.id

  tags = {
    Name = "${var.instanceTagName}"
  }

  provisioner "local-exec" {
    command = "echo 'resource executed successfully created'"
  }
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-imported-key-v2"
  public_key = var.public_key_material
}

resource "aws_security_group" "webserver_sg" {
  name        = var.sg_name
  description = "Webserver Security Group Allow port 80"
  vpc_id      = aws_vpc.myVpc-v2.id

  dynamic "ingress" {
    for_each = [80, 22, 8080, 3000, 9090]
    content { 
      description = "---"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "configureAnsibleInventory" {
  triggers = {
    mytrigger = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo [prod] > inventory"
  }
}

resource "null_resource" "configureansibleinventoryIPdetails" {
  triggers = {
    mytrigger = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=mykey >> inventory"
  }
}

resource "null_resource" "destroy_resource" {
  provisioner "local-exec" {
    when    = destroy
    command = "echo destroying resources.. > gfgdestroy.txt"
  }
}