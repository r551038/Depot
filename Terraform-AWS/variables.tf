variable "cidr_blockselc" {
  type = map(string)
  default = {
    "prod" = "10.0.0.0/16"
    "dev"  = "192.168.0.0/16"
  }
}


variable "cidr_subselc" {
  type = map(string)
  default = {
    "prod" = "10.0.1.0/24"
    "dev"  = "192.168.1.0/24"
  }
}


variable "priv_ipenvselc" {
  type = map(string)
  default = {
    "prod" = "10.0.1.40"
    "dev"  = "192.168.1.40"
  }

}

