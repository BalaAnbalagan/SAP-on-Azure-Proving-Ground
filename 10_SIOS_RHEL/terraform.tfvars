sid = "S4P"

# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "SIOS_RHEL"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-SIOS"

location = "WESTUS2"

# SCS Variables
scs_VMPublisherName = "RedHat"
scs_VMOffer = "RHEL"
scs_VMImageSku = "7-RAW-CI"
scs_vm_type = "Standard_D2s_v3"
scs_CloudinitscriptPath = "/modules/scs_server/ps_ascs.bash"
scs_server_hostnamelist = ["azrhascs1", "azrhascs2"]
scs_server_niclist = ["11.1.2.11", "11.1.2.12"]
scs_ipmap = {
  "azrhascs1" = "11.1.2.11"
  "azrhascs2" = "11.1.2.12"
}



# Web Dispatcher

wd_vm_type = "Standard_D2s_v3"

wd_server_hostnamelist = ["azrhwd1", "azrhwd2"]

wd_server_niclist = ["11.1.2.13", "11.1.2.14"]

wd_ipmap = {
  "azrhwd1" = "11.1.2.13"
  "azrhwd2" = "11.1.2.14"
}
wd_CloudinitscriptPath = "../modules/wd_server/ps.wd.bash"

sios_vm_type = "Standard_B2s"

sios_server_hostnamelist = ["azrhwit1", "azrhwit2"]

sios_server_niclist = ["11.1.2.15", "11.1.2.16"]

sios_ipmap = {
  "azrhwit1" = "11.1.2.15"
  "azrhwit2" = "11.1.2.16"
}
sios_CloudinitscriptPath =  "../modules/sios_server/ps.sios.bash"
# Application Server

app_vm_type = "Standard_D4s_v3"
 
app_server_hostnamelist = ["azrhsap1", "azrhsap2"]

app_server_niclist = ["11.1.2.21", "11.1.2.22"]

app_server_ipmap = {
  "azrhsap1" = "11.1.2.21"
  "azrhsap2" = "11.1.2.22"
}

app_CloudinitscriptPath = "../modules/app_server/ps.app.bash"

# Database Server
db_VMPublisherName="RedHat"
db_VMOffer = "RHEL-SAP"
db_VMImageSku = "7.4"
db_VMSize = "Standard_M8ms"

db_server_hostnamelist = ["azrhhana1", "azrhhana2"]

db_server_niclist = ["11.1.2.31", "11.1.2.32"]

db_server_ipmap = {
  "azrhhana1" = "11.1.2.31"
  "azrhhana2" = "11.1.2.32"
}

db_CloudinitscriptPath =  "/modules/scs_server/ps.db.bash" ## The Cloud-init script path
  

# Generic parameter
# The VM Admin Name
VMAdminName = "cloud-user"


#The VM Admin Password

VMAdminPassword = "Password1234!"
 

# VM images info
#get appropriate image info with the following command
#Get-AzureRMVMImagePublisher -location WestEurope
#Get-AzureRMVMImageOffer -location WestEurope -PublisherName <PublisherName>
#Get-AzureRmVMImageSku -Location westeurope -Offer <OfferName> -PublisherName <PublisherName>
#VMPublisherName = RedHat
#VMOffer = RHEL-SAP
#VMImageSku = 7.4

#The boot diagnostic storage uri

DiagnosticDiskURI = "https://rhelbootdiagstrg.blob.core.windows.net/"

# credits
# http://teknews.cloud/bootstrapping-azure-vms-with-terraform/
