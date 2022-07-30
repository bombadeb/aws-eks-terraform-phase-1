#Create VPC 
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "main"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw"
    }
}


#Private Subnet - US-EAST-1A
resource "aws_subnet" "private-us-east-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1a"

    tags = {
      "Name" = "private-us-east-1a"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/demo" = "owned"
    }
}

#Private Subnet - US-EAST-1B
resource "aws_subnet" "private-us-east-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1b"

    tags = {
      "Name" = "private-us-east-1a"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/demo" = "owned"
    }
}

#Public Subnet - US-EAST-1A
resource "aws_subnet" "public-us-east-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "public-us-east-1a"
      "kubernetes.io/role/elb" = "1"
      "kubernetes.io/cluster/demo" = "owned"
    }
}

#Public Subnet - US-EAST-1B
resource "aws_subnet" "public-us-east-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "public-us-east-1b"
      "kubernetes.io/role/elb" = "1"
      "kubernetes.io/cluster/demo" = "owned"
    }
}

resource "aws_eip" "nat" {
    vpc = true

    tags = {
      "Name" = "NAT-Gateway"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public-us-east-1a.id

    tags = {
      "Name" = "NAT-Gateway"
    }

    depends_on = [aws_internet_gateway.igw]
}

#Route Table for Private
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block      = "0.0.0.0/0"
            nat_gateway_id  = aws_nat_gateway.nat.id
        }
    ]

    tags = {
      "Name" = "Private Association"
    }
}

#Route Table for Public
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block      = "0.0.0.0/0"
            nat_gateway_id  = aws_internet_gateway.igw.id
        }
    ]

    tags = {
      "Name" = "Public Association"
    }
}

#Route Table association 
resource "aws_route_table_association" "private-us-east-1a" {
    subnet_id = aws_subnet.private-us-east-1a.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
    subnet_id = aws_subnet.private-us-east-1b.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1a" {
    subnet_id = aws_subnet.private-us-east-1a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-1a" {
    subnet_id = aws_subnet.private-us-east-1a.id
    route_table_id = aws_route_table.public.id
}
