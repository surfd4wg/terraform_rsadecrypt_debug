variable "access_key" {
  description = "Access Key to AWS account"
  default     = ""
}

variable "secret_key" {
  description = "Secret Key to AWS account"
  default     = ""
}

variable "public_key_path" {
  description = "Path to the public SSH key you want to bake into the instance."
  default     = "~/.ssh/xxx.pub"
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/xxx.pem"
}

variable "admin_password" {
  description = "Windows Administrator password to login as for provisioning"
  default = "XXXX1234567890"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "xxxxxxx"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_availzone" {
  description = "AWS availibility zone to launch in."
  default     = "us-east-1a"
}

variable "instance_name" {
  description = "Name of your instance"
  default     = "Windows"
}

variable "INSTANCE_USERNAME" {
  description = "user"
  default = "user1"
}

variable "INSTANCE_PASSWORD" {
  description = "pass"
  default = "XXXX1234567890"
}

variable "instance_count" {
  description = "number of instances to spin up"
  default = 2
}

variable "pbase" {
  type = string
  default = ""
}

variable "ptext" {
  type = string
  default = ""
}
