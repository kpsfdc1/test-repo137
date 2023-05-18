provider "aws"{
	region = "ap-south-1"
}

terraform {
	backend "s3"{
		bucket = "capital-s3-bucket"
		key = "terraform.tfstate"
		region = "ap-south-1"
	}
}

resource "aws_vpc" "tf_new_vpc" {
	cidr_block = "10.0.0.0/16"
	tags = {
		Name = "tf_new_vpc"
	}
	enable_dns_support   = true
        enable_dns_hostnames = true
}

resource "aws_internet_gateway" "tf_new_vpc_igw" {
	vpc_id = aws_vpc.tf_new_vpc.id
	tags = {
		Name = "tf_new_vpc_igw"
	}
}

resource "aws_subnet" "tf_new_vpc_pub_subnet" {
	vpc_id = aws_vpc.tf_new_vpc.id
	cidr_block = "10.0.0.0/24"
	availability_zone = "ap-south-1a"
	map_public_ip_on_launch = "true"
	tags = {
		Name = "tf_new_vpc_pub_subnet"
	}
}

resource "aws_route_table" "tf_new_vpc_rtb" {
	vpc_id = aws_vpc.tf_new_vpc.id
	tags = {
		Name = "tf_new_vpc_rtb"
	}
	route  {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.tf_new_vpc_igw.id 
	}
	
}

resource "aws_route_table_association" "aws_rtb_assoct" {
	subnet_id = aws_subnet.tf_new_vpc_pub_subnet.id
	route_table_id = aws_route_table.tf_new_vpc_rtb.id
}

resource "aws_security_group" "sg_22" {
	name = "sg_22"
	vpc_id = aws_vpc.tf_new_vpc.id
	ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
	tags = {
		Name = "tf_new_vpc_sg"
	}
}

resource "aws_instance" "tf_new_vpc_inst" {
	ami = "ami-03a933af70fa97ad2"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.tf_new_vpc_pub_subnet.id
	vpc_security_group_ids = [aws_security_group.sg_22.id]
	key_name = "linux-prac-inst1"
	tags = {
		Name = "tf_new_vpc_pub_subnet_inst"
	}
}
