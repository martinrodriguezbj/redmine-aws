# --- VPC ---
resource "aws_vpc" "redmine" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "redmine-vpc" }
}

# --- Subnets públicas en dos AZs ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.redmine.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "redmine-public-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.redmine.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "redmine-public-subnet-b" }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.redmine.id

  tags = { Name = "redmine-igw" }
}

# --- Tabla de ruteo ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.redmine.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "redmine-public-rt" }
}

# --- Asociaciones de tabla de ruteo ---
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group para EC2 ---
resource "aws_security_group" "ec2_sg" {
  name   = "redmine-ec2-sg"
  vpc_id = aws_vpc.redmine.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
}

# --- Security Group para RDS ---
resource "aws_security_group" "rds_sg" {
  name   = "redmine-rds-sg"
  vpc_id = aws_vpc.redmine.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Key Pair usando tu clave pública ---
resource "aws_key_pair" "default" {
  key_name   = "redmine-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# --- Instancia EC2 ---
resource "aws_instance" "redmine" {
  ami                    = "ami-0779caf41f9ba54f0" # Debian
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.default.key_name

  tags = { Name = "redmine-ec2" }
}

# --- Subnet Group para RDS ---
resource "aws_db_subnet_group" "redmine" {
  name       = "redmine-db-subnet-group"
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = { Name = "redmine-db-subnet-group" }
}

# --- RDS MySQL ---
resource "aws_db_instance" "redmine" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "redmine"
  username               = "redmine"
  password               = "redmine123"
  db_subnet_group_name   = aws_db_subnet_group.redmine.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = { Name = "redmine-rds" }
}

# --- Outputs ---
output "ec2_public_ip" {
  value = aws_instance.redmine.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.redmine.address
}
