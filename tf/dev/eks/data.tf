##########
# VPC ID
##########
data "aws_vpcs" "this" {
  tags = {
    Name = var.vpc_name
  }
}

# This source is required to get the vpc cidr block which is not available from aws_vpcs
data "aws_vpc" "this" {
  id = element(tolist(data.aws_vpcs.this.ids),1)
}

##########
# VPC Subnets
##########

# Private
data "aws_subnet_ids" "private" {
  vpc_id =  element(tolist(data.aws_vpcs.this.ids),1)

  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
    count = length(data.aws_subnet_ids.private.ids)
    id    = tolist(data.aws_subnet_ids.private.ids)[count.index]
}


# Public
data "aws_subnet_ids" "public" {
  vpc_id =  element(tolist(data.aws_vpcs.this.ids),1)

  tags = {
    Tier = "Public"
  }
}

data "aws_subnet" "public" {
    count = length(data.aws_subnet_ids.public.ids)
    id    = tolist(data.aws_subnet_ids.public.ids)[count.index]
}


# All
data "aws_subnet_ids" "all" {
  vpc_id =  element(tolist(data.aws_vpcs.this.ids),1)
}

data "aws_subnet" "all" {
    count = length(data.aws_subnet_ids.all.ids)
    id    = tolist(data.aws_subnet_ids.all.ids)[count.index]
}


#########
# Outputs
#########
/*
output "all_subnets" {
  value =  data.aws_subnet.all.*.id
}

output "private_subnets" {
  value =  data.aws_subnet.private.*.id
}

output "public_subnets" {
  value =  data.aws_subnet.public.*.id
}

output "subnet_cidr_blocks" {
  value = data.aws_subnet.all.*.cidr_block
}

output "vpc_cidr" {
  value = data.aws_vpc.this.cidr_block
}

output "vpc_id" {
  value =  element(tolist(data.aws_vpcs.this.ids),1)
}
*/
