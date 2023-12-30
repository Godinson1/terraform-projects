provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_blocks
  instance_tenancy = var.instance_tenancy

  tags = {
    Name: "${var.app_name}-${var.env_prefix}-vpc"
  }
}

module "app-subnet" {
    source = "./modules/subnet"
    app_name = var.app_name
    aws_region = var.aws_region
    vpc_id = aws_vpc.app-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    env_prefix = var.env_prefix
    availability_zone = var.availability_zone
    default_route_table_id = aws_vpc.app-vpc.default_route_table_id
}

module "app-server" {
    source = "./modules/web-server"
    app_name = var.app_name
    aws_region = var.aws_region
    vpc_id = aws_vpc.app-vpc.id
    env_prefix = var.env_prefix
    availability_zone = var.availability_zone
    instance_type = var.instance_type
    subnet_id = module.app-subnet.subnet.id
    my_ip = var.my_ip
    app_port = var.app_port
    image_name = var.image_name
    ami_image_owner = var.ami_image_owner
    key_name = var.key_name
    public_key_location = var.public_key_location
}