resource "aws_vpc" "infra" {
  
  cidr_block = "10.0.0.0/16"

  
}


resource "aws_subnet" "PubSub" {
  
  vpc_id                  = aws_vpc.infra.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

}

resource "aws_subnet" "PubSub2" {
  
  vpc_id                  = aws_vpc.infra.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "iginfra" {
  vpc_id = aws_vpc.infra.id


}
resource "aws_route_table" "RTinfra" {
  vpc_id = aws_vpc.infra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iginfra.id

  }

}

resource "aws_route_table_association" "rttosub1" {

  subnet_id      = aws_subnet.PubSub.id
  route_table_id = aws_route_table.RTinfra.id
}

resource "aws_route_table_association" "rttosub2" {

  subnet_id      = aws_subnet.PubSub2.id
  route_table_id = aws_route_table.RTinfra.id
}

resource "aws_security_group" "websg" {
  name        = "websg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.infra.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "Infra-Bucket-for-iac" {
  bucket = "yfjujgdhgdjhfghjdgd5454545"


}

resource "aws_s3_bucket_public_access_block" "pba" {
bucket = aws_s3_bucket.Infra-Bucket-for-iac.id
block_public_acls = false
block_public_policy = false
ignore_public_acls = false
restrict_public_buckets = false
  
}
resource "aws_instance" "webserver1" {
    
    ami = "ami-053b0d53c279acc90"
   instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.PubSub.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
    
ami = "ami-053b0d53c279acc90"
 instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.PubSub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.websg.id]
  subnets         = [aws_subnet.PubSub.id, aws_subnet.PubSub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.infra.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}