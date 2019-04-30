sid = "AS1"

# Resource Group Name will be RG-<SID>-<LOCATION> & RG will be hard coded
rg = "SUSE-ASE"

network_rg = "NETWORK"

vnet = "SPOKE"

subnet = "SPOKE-ASE"

location = "WESTUS2"

# SCS Variables

scs_vm_type = "Standard_D2s_v3"

scs_server_hostnamelist = ["azsuascs1", "azsuers1"]

scs_server_niclist = ["11.1.4.1", "11.1.4.2"]

scs_ipmap = {
  "azsuascs1" = "11.1.4.1"
  "azsuers1" = "11.1.4.2"
}

wd_vm_type = "Standard_D2s_v3"

wd_server_hostnamelist = ["azrhs4p13", "azrhs4p14"]

wd_server_niclist = ["11.1.4.3", "11.1.4.4"]

wd_ipmap = {
  "azrhs4p13" = "11.1.4.3"
  "azrhs4p14" = "11.1.4.4"
}

sios_vm_type = "Standard_B2s"

sios_server_hostnamelist = ["azsusapwit1", "azsusapwit2" ]

sios_server_niclist = ["11.1.4.65", "11.1.4.66"]

sios_ipmap = {
  "azsusapwit1" = "11.1.4.65"
  "azsusapwit2" = "11.1.4.66"
}

app_vm_type = "Standard_D4s_v3"
 
app_server_hostnamelist = ["azsusap1", "azsusap2"]

app_server_niclist = ["11.1.4.11", "11.1.4.12"]

app_server_ipmap = {
  "azsusap1" = "11.1.4.11"
  "azsusap2" = "11.1.4.12"
}

db_vm_type = "Standard_E4S_V3"

db_server_hostnamelist = ["azsuase1", "azsuase2"]

db_server_niclist = ["11.1.4.21", "11.1.4.22"]

db_server_ipmap = {
  "azsuase1" = "11.1.4.21"
  "azsuase2" = "11.1.4.22"
}

