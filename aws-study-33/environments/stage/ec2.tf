data "aws_ssm_parameter" "ami_al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "ec2" {
  ami                     = data.aws_ssm_parameter.ami_al2023.value
  instance_type           = var.ec2_instance_config
  tenancy                 = "default"
  key_name                = "aws-study-re"
  disable_api_termination = false

  subnet_id              = module.vpc.public_subnet_ids["public-1a"]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    "Name" = "${var.pj_prefix}-terraform-${var.my_env}-ec2"
  }
}

# SecuriryGroup
resource "aws_security_group" "ec2_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.pj_prefix}-terraform-${var.my_env}-ec2-sg"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj_prefix}-terraform-${var.my_env}-ec2-sg"
  }
}
