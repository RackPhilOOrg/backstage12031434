variable "location" {
  default = "uksouth"
}

variable "computeResourceGroupName" {
  default = "rg-compute"
}

variable "networkResourceGroupName" {
  default = "rg-network"
}

variable "virtual_machines" {
  default = {
    "windows1" = {
      lb_frontend_nat_rdp_port   = "50601"
      lb_frontend_nat_ssh_port   = "50602"
      lb_frontend_nat_winrm_port = "50603"
    },
    "windows2" = {
      lb_frontend_nat_rdp_port   = "50604"
      lb_frontend_nat_ssh_port   = "50605"
      lb_frontend_nat_winrm_port = "50606"
    }
  }
}

locals {
  common_tags = {
    repo = "backstage12031434"
  }
}
