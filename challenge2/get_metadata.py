import urllib.request, urllib.parse
import json, sys, os
from typing import Union
from configparser import ConfigParser

# append the parent folder file path for import the modules 
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from challenge3.deep_get import get_value_by_key

# configurations
"""
config filename: config.ini
config format
***************
[main]
tenant_id = ""
client_id = ""
client_secret = ""

subscription_id = ""
resource_group_name = ""
vm_name = ""

metadata_key = "properties/vmId"
"""

def get_aad_bearer_token(config : any) -> Union[str, None]:
  """Get a bearer token from Azure Active Directory

  Returns:
      str | None: Bearer token, which is valid for 1 hour
  """
  
  tenant_id = config.get("main", "tenant_id")
  client_id = config.get("main", "client_id")
  client_secret = config.get("main", "client_secret")
  grant_type = config.get("main", "grant_type")
  resource = config.get("main", "resource")
  aad_auth_url = config.get("main", "aad_auth_url")
   
  post_body_key_values = {'client_id': client_id,
                          'client_secret': client_secret,
                          'grant_type': grant_type,
                          'resource': resource
                          }
  headers = {}
  auth_url = aad_auth_url.format(tenant_id=tenant_id)
  post_body = urllib.parse.urlencode(post_body_key_values)
  post_body = post_body.encode('ascii')
  req = urllib.request.Request(auth_url, post_body, headers)
  with urllib.request.urlopen(req) as response:
    
    if(response.code != 200):
      print("Not able to get the bearer token")
      return None
    
    response_data = response.read()
    res_json_data = json.loads(response_data.decode('utf-8'))    
    return res_json_data["access_token"]
      

def get_metadata(config: any, bearer_token : str) -> any:
  """Get the metadata of the resource in Azure

  Returns:
      any: The instance metadata in the json format
  """  
  
  az_resource_mgmt_url = config.get("main", "az_resource_mgmt_url")
  subscription_id = config.get("main", "subscription_id")
  resource_group_name = config.get("main", "subscription_id")
  vm_name = config.get("main", "vm_name")
  
  resource_mgmt_url = az_resource_mgmt_url.format(
                                              subscription_id=subscription_id, 
                                              resource_group_name=resource_group_name, 
                                              vm_name=vm_name)  
  req = urllib.request.Request(resource_mgmt_url)
  req.add_header('Authorization', 'Bearer %s' % bearer_token)
  with urllib.request.urlopen(req, ) as response:
    
    if(response.code != 200):
      print("Not able to retrive the metadata for the instance - {}".format(vm_name))
      return None
    
    response_data = response.read()
    res_json_data = json.loads(response_data.decode('utf-8'))      
    return res_json_data
      

def main():
  # Config file relative path
  config_file_path = "challenge2/config.ini"

  config = ConfigParser()

  config.read(config_file_path)
  

  # Get bearer token and it's valid for one hour
  bearer_token = get_aad_bearer_token(config)

  if bearer_token is None:
    print("Not able to get the bearer token, so the function is stopped")
    quit()

  metadata = get_metadata(config, bearer_token)
  
  if metadata is None:
    quit()
  
  print("Metadata\r\n**********************\r\n")
  print(metadata)
  print("\r\n**********************\r\n")

  metadata_key = config.get("main", "metadata_key")
  metadata_value = get_value_by_key(metadata, metadata_key)
  
  if metadata_value is not None:
    print("Value for the metadata key - '{0}' is -> {1}".format(metadata_key, metadata_value))
  else:
    print("No value for the metadata key - '{0}'".format(metadata_key))

if __name__ == "__main__":
   main()