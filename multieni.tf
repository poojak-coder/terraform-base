# Specify AWS provider for Ohio
provider "aws" {
  region = "us-east-2"  # Ohio region
}

# Specify AWS provider for North Virginia
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"  # North Virginia region
}

# Data sources for Ohio subnets by availability zone
data "aws_subnet_ids" "ohio_subnets" {
  for_each = {
    "us-east-2a" = "your_subnet_id_in_us-east-2a",  # Replace with actual subnet IDs
    "us-east-2b" = "your_subnet_id_in_us-east-2b",
    "us-east-2c" = "your_subnet_id_in_us-east-2c"
  }

  ids = values(each.value)
}

# Data sources for North Virginia subnets by availability zone (A and B)
data "aws_subnet_ids" "virginia_subnets" {
  for_each = {
    "us-east-1a" = "your_subnet_id_in_us-east-1a",  # Replace with actual subnet IDs
    "us-east-1b" = "your_subnet_id_in_us-east-1b"
  }

  ids = values(each.value)
}

# Define EC2 instances in Ohio across AZs
resource "aws_instance" "ohio_instances" {
  count         = length(data.aws_subnet_ids.ohio_subnets)
  ami           = "ami-xxxxxxxxxxxxxxxxx"  # Replace with your Windows AMI ID
  instance_type = "t2.medium"  # Replace with your desired instance type
  subnet_id     = values(data.aws_subnet_ids.ohio_subnets)[count.index]

  # Optionally, configure other instance details like tags, key_name, etc.
}

# Define EC2 instances in North Virginia AZs A and B
resource "aws_instance" "virginia_instances" {
  count         = 2
  ami           = "ami-xxxxxxxxxxxxxxxxx"  # Replace with your Windows AMI ID
  instance_type = "t2.medium"  # Replace with your desired instance type
  subnet_id     = values(data.aws_subnet_ids.virginia_subnets)[count.index % length(data.aws_subnet_ids.virginia_subnets)]

  # Optionally, configure other instance details like tags, key_name, etc.
}

# Define ENIs with consecutive IP addresses for Ohio instances
resource "aws_network_interface" "ohio_enis" {
  count       = length(aws_instance.ohio_instances)
  subnet_id   = aws_instance.ohio_instances[count.index].subnet_id
  private_ips = slice(data.aws_subnet_ids.ohio_subnets[aws_instance.ohio_instances[count.index].availability_zone], count.index, 15)

  # Optionally, configure other ENI details like tags, security_groups, etc.
}

# Define ENIs with consecutive IP addresses for North Virginia instances
resource "aws_network_interface" "virginia_enis" {
  count       = length(aws_instance.virginia_instances)
  subnet_id   = aws_instance.virginia_instances[count.index].subnet_id
  private_ips = slice(data.aws_subnet_ids.virginia_subnets[aws_instance.virginia_instances[count.index].availability_zone], count.index, 15)

  # Optionally, configure other ENI details like tags, security_groups, etc.
}