

resource "aws_vpc_endpoint" "vpc_s3_private_endpoint" {
  vpc_id            = aws_vpc.test-vpc.id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.cs6-private-route.id]

  private_dns_enabled = false
  tags = merge(
    {
      "Name" = "vpc-s3-private-endpoint"
    }
  )
}
