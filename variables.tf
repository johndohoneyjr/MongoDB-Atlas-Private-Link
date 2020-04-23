
# atlas regions use the underscore, opposed to hyphen -- not my idea :)
variable "atlas-region" {}
variable "region" {}

variable "az1" {}

variable "az2" {}

variable "mongo-centos-ami" { }
  # US-West-1 AMI: ami-0fcb09de99f2fc888
  # US-West-2 AMI: ami-070c05f37f34494a3
  # US_West-2 Ubuntu - ami-0b8ba4463d4a65efd


variable "atlas-aws-cidr" {}
variable "amazon-account-number" {}
variable "atlas-public-key" {}
variable "atlas-private-key" {}

variable "atlas-project-id" {}

variable "atlas-cloud-provider" {}

variable "atlas-reg" {}

variable "scenario" {}

variable "public_key" {}
