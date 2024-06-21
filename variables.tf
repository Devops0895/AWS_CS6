#218453391514

# variable "key_name" {
#   type        = string
#   description = "used to SSH the server"
#   default     = "private"
# }

variable "availability_zones" {
  type    = string
  default = "us-west-2a" #need to update AZ according to the country
}

variable "subnet_names" {
  type    = string
  default = "pub-subnet-1" #should update the name accordingly
}

variable "instance_names" {
  type    = string
  default = "one"
}

# variable "instance_count" {
#   #to execute this variable we need to add count = var.instance_count
#   description = "Number of instances to launch"
#   default     = 1
# }


variable "region" {
  description = "region which we are working"
  default     = "us-west-2"
}

variable "cloudtrail_name" {
  default     = "ec2-s3-logging-cloud-trail"
  description = "this is for logging the events for ec2 and s3 bucket tasks"
}


# key pair - Location to the SSH Key generate using openssl or ssh-keygen or AWS KeyPair
# variable "ssh_pubkey_file" {
#   description = "Path to an SSH public key"
#   default     = "C:/Users/SaiS2.MUMBAI1/.ssh/id_rsa.pub"
# }


