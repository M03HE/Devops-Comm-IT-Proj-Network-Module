### VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block           = local.cidr_block
  enable_dns_support   = "true" #give u an internal domain name
  enable_dns_hostnames = "true" #give u an internal host name
  instance_tenancy     = "default"
  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-subnet-public-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = local.public_subnets_cidr_block
  map_public_ip_on_launch = "true" #make the subnet public
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "prod-subnet-public-1"
  }
}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-igw"
  }
}

resource "aws_route_table" "prod-public-rt" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //rt uses this IGW to reach the internet 
    gateway_id = aws_internet_gateway.prod-igw.id
  }
  tags = {
    Name = "prod-public-rt"
  }
}

resource "aws_route_table_association" "prod-rta-public-subnet-1" {
  subnet_id      = aws_subnet.prod-subnet-public-1.id
  route_table_id = aws_route_table.prod-public-rt.id
}

resource "aws_security_group" "ssh-allowed" {
  name   = "${local.name} Security Group"
  vpc_id = aws_vpc.prod-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.security_access
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.security_access
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = local.security_access
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = local.security_access
  }
  tags = {
    Name = "ssh-allowed"
  }
}

###EC2
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${local.key_name}.pem"
  content         = tls_private_key.demo_key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "instance" {
  ami                         = lookup(var.AMI, var.AWS_REGION)
  subnet_id                   = aws_subnet.prod-subnet-public-1.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  key_name                    = local.key_name
  vpc_security_group_ids      = [aws_security_group.ssh-allowed.id]

  provisioner "remote-exec" {
    inline = ["echo 'Wait untill SSH is ready'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = local_file.ssh_key.content
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, --private-key ${local.private_key_path} jenkins.yaml"
  }
}
###ROUTE 53
# resource "aws_route53_zone" "hosted_zone" {
#   name = "moshe.one"
# }
# resource "aws_route53_record" "www" {
#   depends_on = [aws_instance.instance]
#   zone_id    = aws_route53_zone.hosted_zone.zone_id
#   name       = "www"
#   type       = "A"
#   ttl        = 300
#   records    = [aws_instance.instance.public_ip]
# }



