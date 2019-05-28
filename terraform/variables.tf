variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyl6AXFEtcUnYkc7RY3H2XrXUcN5tIgckdXDWfLffXi5Tu5hGUSmlYVjR06RWKFDseFULYl+J2OH+P8Dodb/enwGKmSnCvqk0EYqFVxDv1hs5kzHYr70v4MkUGfw+MeRQMK4r8hLKzVLx0uksif/Ii53c/ooNOikM61c0EAd/VyUH3WyFXdwrIA1ufS6Rudzn+og5CAIoENJpowvBxLzrXFeu0J8wwncijJXxhn1C/P4SdC8Lj1/5gLA+6zhdQxUTxm04EADyAcHPLko85pOGciD5x3YXafpp58BeaOr0c9jOp6NaxL+WRl1RA54ojR3MJbNxy0xBabfi0xXdflekH qoden@MacBook-Pro-Roman.local"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "qoden"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-north-1"
}

variable "vpc_id" {
  description = "AWS VPC id"
  default = "vpc-2bc40142"
  
}
