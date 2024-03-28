resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instances"

  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH access from your local machine
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your local IP address
  }

  # Allow HTTP access (port 80) for NGINX
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere (or restrict to specific IPs if needed)
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Public EC2 Instance
resource "aws_instance" "public_instance" {
  ami           = "ami-007020fd9c84e18c7" # Replace with your AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.example_keypair.key_name  # Corrected reference
  security_groups = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "Public Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              EOF
}

# Private EC2 Instance
resource "aws_instance" "private_instance" {
  ami             = "ami-007020fd9c84e18c7" # Replace with your AMI ID
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet.id
  key_name        = aws_key_pair.example_keypair.key_name  # Corrected reference
  security_groups = [aws_security_group.ec2_security_group.id]


  tags = {
    Name = "Private Instance"
  }
}