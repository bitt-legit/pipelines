variable "company_prefix" {
  type        = string
  description = "This is a company identifier that will be prefixed to many of the created resources"
}

variable "fb_data_node_type" {
  type    = string
  default = "c5.9xlarge"
}

variable "fb_data_node_count" {
  type    = number
  default = 3
}

variable "subnet" {
  default = ""
}

variable "zone" {
  default = ""
}

variable "fb_data_disk_type" {
  default = "gp3"
}
variable "fb_data_disk_iops" {
  default = 1000
}

variable "fb_data_disk_size_gb" {
  default = 100
}

variable "azs" {
  type    = list(any)
  default = ["us-east-2a", "us-east-2a", "us-east-2a"]
}

variable "private_subnets" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
