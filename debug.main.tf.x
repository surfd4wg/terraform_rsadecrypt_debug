# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    tags ={
        name = "Main VPC"
    }
}

resource "aws_internet_gateway" "main" { 
    vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.15.0/24"
    availability_zone = var.aws_availzone
}

resource "aws_route_table" "default"{
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.default.id
}

resource "aws_eip" "webserver" {
#    instance = aws_instance.winrm.id 
    count = var.instance_count
    instance = aws_instance.winrm[count.index].id
    vpc = true  
    depends_on = [aws_internet_gateway.main]
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }

}

resource "aws_instance" "winrm" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance) using WinRM
    get_password_data = true
    connection {
      host = self.public_ip
      type     = "winrm"
      user     = "Administrator"
     private_key = file(var.private_key_path)
    timeout = "30m"
    }

  # Change instance type for appropriate use case
    instance_type = "t2.micro"
 
  #ami    
  #  ami = "ami-056f139b85f494248"
  # ami = "ami-04c7f5a0e4cc067e0"
  ami = data.aws_ami.amazon_windows_2012R2.image_id
  # Root storage
  # Terraform doesn't allow encryption of root at this time
  # encrypt volume after deployment.
  root_block_device {
    volume_type = "gp2"
    volume_size = 40
    delete_on_termination = true
  }

  # AZ to launch in
  availability_zone = var.aws_availzone

  # VPC subnet and SGs
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allowall.id]
  associate_public_ip_address = "true"

  # The number of instances to spin up
  count = var.instance_count
  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs
  #
  key_name = var.key_name
#  admin_password_base = aws_instance.winrm.*.password_data

# Ec2 user data, WinRM and PowerShell Provision Functions
   user_data = <<EOF
	<powershell>
	#Allow All TLS versions 
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
		[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
	#Windows Remoting
		net user ${var.INSTANCE_USERNAME} '${var.INSTANCE_PASSWORD}' /add /y
		net localgroup administrators ${var.INSTANCE_USERNAME} /add
		winrm quickconfig -q
		winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
		winrm set winrm/config '@{MaxTimeoutms="1800000"}'
		winrm set winrm/config/service '@{AllowUnencrypted="true"}'
		winrm set winrm/config/service/auth '@{Basic="true"}'
		netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
		netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
		net stop winrm
		sc.exe config winrm start=auto
		net start winrm

	</powershell>
	EOF

	tags = {
		#Name = var.instance_name
		Name = "Terraform-${count.index + 1}"
	}

}

