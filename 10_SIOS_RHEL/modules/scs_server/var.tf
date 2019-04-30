variable "environment" {
  description = "Enviroment Prod or non-prod"
  default     = "Production"
}

variable "sid" {
  description = "SAP SID"
  default     = "W3Z"
}

variable "location" {
  description = "Azure Regions"
  default     = "WESTUS2"
}

variable "rg" {
  description = "resource group"
  default     = ""
}

variable "network_rg" {
  description = "resource group"
  default     = ""
}

variable "vnet" {
  description = "Name of the vnet"
  default     = "SPOKE"
}
variable "subnet" {
  description = "Name of the subnet"
  default     = "Subnet"
}
variable "scs_vm_type" {
  default = ""
}

variable "scs_server_hostnamelist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "scs_server_niclist" {
  description = "list of Ethernets"
  type        = "list"
  default     = []
}

variable "scs_ipmap" {
  description = "hostname vs ip address"
  type        = "map"
  default     = {}
}

variable "backup" {
  default = "false"
}

variable "tags_map" {
  description = "Map of tags and values"
  type        = "map"
  default     = {}
}

#The Cloud-init script path

variable "scs_CloudinitscriptPath" {
  type = "string"
}

#The VM Admin Name

variable "VMAdminName" {
  type    = "string"
 # default = "VMAdmin"
}

#The VM Admin Password

variable "VMAdminPassword" {
  type = "string"
}

# VM images info
#get appropriate image info with the following command
#Get-AzureRMVMImagePublisher -location WestEurope
#Get-AzureRMVMImageOffer -location WestEurope -PublisherName <PublisherName>
#Get-AzureRmVMImageSku -Location westeurope -Offer <OfferName> -PublisherName <PublisherName>

variable "scs_VMPublisherName" {
  type = "string"
}

variable "scs_VMOffer" {
  type = "string"
}

variable "scs_VMImageSku" {
  type = "string"
}

#The boot diagnostic storage uri

variable "DiagnosticDiskURI" {
  type = "string"
}