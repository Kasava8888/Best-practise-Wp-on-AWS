resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        Name = "${var.project_name} - vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
    tags = {
        Name = "${var.project_name} - igw"
    }
}  
data "aws_availability_zones" "AZs"{
    state = "available"
}

resource "aws_subnet" "pub_sub_az1" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[0]
    cidr_block = var.cidr_pub_sub_az1
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name} - pub_sub_az1"
    }
  
}

resource "aws_subnet" "pub_sub_az2" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[1]
    cidr_block = var.cidr_pub_sub_az2
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name} - pub_sub_az2"
    }
  
}


resource "aws_route_table" "rtb_pub" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block= "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.project_name} - rtb_pub"
    }
}

resource "aws_route_table_association" "rtb_pub_AZ1" {
  subnet_id = aws_subnet.pub_sub_az1.id
  route_table_id = aws_route_table.rtb_pub.id
}

resource "aws_route_table_association" "rtb_pub_AZ2" {
  subnet_id = aws_subnet.pub_sub_az2.id
  route_table_id = aws_route_table.rtb_pub.id
}
resource "aws_subnet" "pri_sub_az1" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[0]
    cidr_block = var.cidr_pri_sub_az1
    tags = {
        Name = "${var.project_name} - pri_sub_az1"
    }
  
}

resource "aws_subnet" "pri_sub_az2" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[1]
    cidr_block = var.cidr_pri_sub_az2
    tags = {
        Name = "${var.project_name} - pri_sub_az2"
    }
  
}

resource "aws_subnet" "pri_data_sub_az1" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[0]
    cidr_block = var.cidr_pri_data_sub_az1
    tags = {
        Name = "${var.project_name} - pri_data_sub_az1"
    }
  
}

resource "aws_subnet" "pri_data_sub_az2" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = data.aws_availability_zones.AZs.names[1]
    cidr_block = var.cidr_pri_data_sub_az2
    tags = {
        Name = "${var.project_name} - pri_data_sub_az2"
    }
  
}

resource "aws_eip" "myeip1" {
  domain   = "vpc"
  tags = {
    Name = "natg gw - eip1"
  }
}

resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.myeip1.id
  subnet_id = aws_subnet.pub_sub_az1.id
  tags = {
    Name = "natgw az1 "
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "myeip2" {
  domain   = "vpc"
  tags = {
    Name = "natg gw - eip2"
  }
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.myeip2.id
  subnet_id = aws_subnet.pub_sub_az2.id
  tags = {
    Name = "natgw az2 "
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "rtb_pri_az1" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }
  tags = {
    Name = "private routeable az1"
  }
}

resource "aws_route_table" "rtb_pri_az2" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }
  tags = {
    Name = "private routeable az2"
  }
}
resource "aws_route_table_association" "rtb_pri_az1" {
  subnet_id = aws_subnet.pri_sub_az1.id
  route_table_id = aws_route_table.rtb_pri_az1.id
}



resource "aws_route_table_association" "rtb_pri_az2" {
  subnet_id = aws_subnet.pri_sub_az2.id
  route_table_id = aws_route_table.rtb_pri_az2.id
}

