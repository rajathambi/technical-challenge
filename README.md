# Technical Challenge

Challenge #1
************
Solution: Generate the three tier application web application using Azure web apps, Sql server, log analytics workspace, Vnet, keyvault with terraform in Azure cloud

Configuration: Authenticate using the Azure service principle with environment variables - env-variables.sh

Challenge #2
************
Solution: Retrieve the VM metadata from Azure. The client id, client secret, tenant id, subscription id, resource group name and VM name need to be added in the config file.

config filename: config.ini

Format
------------
[main]
tenant_id = ""
client_id = ""
client_secret = ""

subscription_id = ""
resource_group_name = ""
vm_name = ""
------------

Challenge #3
************
Solution: Get the value for the key from the nested object. Execute the python code and python tests