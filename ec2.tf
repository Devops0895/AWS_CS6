
resource "aws_iam_instance_profile" "demo-profile" {
  name = "demo_profile"
  role = aws_iam_role.s3_cw_access_role.name
}

resource "tls_private_key" "private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "cs6_key"
  public_key = tls_private_key.private.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.private.private_key_pem}' > cs6_key.pem"
  }
}

resource "local_file" "tf-key" {
  content  = tls_private_key.private.private_key_pem
  filename = "${path.module}/cs6_key.pem"
}




resource "aws_instance" "instances" {
  ami                    = "ami-0a283ac1aafe112d5" # Replace with your desired AMI ID
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.demo-profile.name
  key_name               = "cs6_key"


  tags = {
    Name = "cs6-instance"
  }

  user_data = <<EOF
    
  sudo yum upgrade -y
  sudo yum update -y
  sudo ssh-keygen -y
  sudo yum install -y awslogs

  #to modify the default location name and set it to current location
  sed -i "s/us-east-1/us-west-2/g" /etc/awslogs/awscli.conf

  #start the aws logs agent
  sudo systemctl start awslogsd

  #start the service at each system boot.
  sudo systemctl enable awslogsd.service

  #echo -e "#!/bin/bash\#this script is for access the s3 buckets present in the appropriate account\aws s3 ec2-access-logging-bucket-112233 ls >> /home/ec2-user/userdata.sh
  #sudo ./home/ec2-user/userdata.sh
  #sudo bash /home/ec2-user/uuserdata-cs6.sh
  EOF
}


# resource "null_resource" "execute_script_default_installations" {
#   depends_on = [local_file.tf-key, aws_key_pair.generated_key]

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file("./cs6_key.pem")
#     host        = aws_instance.instances.public_ip
#   }

#   provisioner "file" {
#     source      = "userdata-cs6.sh"
#     destination = "/home/ec2-user/userdata-cs6.sh"
#   }
# }
