# SSH Key Pair (verwende z. B. einen extern erstellten öffentlichen Schlüssel)
resource "aws_key_pair" "cicd_key" {
  key_name   = "cicd-key"
  public_key = var.public_key # <-- direkt aus secret
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cicd-vpc"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.aws_az
  map_public_ip_on_launch = true

  tags = {
    Name = "cicd-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cicd-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cicd-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group (SSH + HTTP)
resource "aws_security_group" "web_sg" {
  name        = "cicd-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Optional: sicherer definieren
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "cicd-sg"
  }
}

# EC2 Instance mit Nginx Installation über user_data
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.cicd_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
              mkdir -p /var/www/html
              echo "<h1>Wartet auf Deploy</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "cicd-ec2-instance"
  }
}
