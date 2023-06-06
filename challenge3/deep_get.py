from functools import reduce
from typing import Union

def get_value_by_key(nested_obj : dict, key: str) -> Union[dict, str, None]:
  """Get the value from the nested object based on the key(s)

  Args:
      nested_obj (dict): Nested object
      key (str): key

  Returns:
      Union[dict, str, None]: Return value based on the key. It should be either dict, str, None
  """  
  split_delimiter = "/"
  keys = key.split(split_delimiter)
  return reduce(lambda x, key: x.get(key, None) if isinstance(x, dict) else None, keys, nested_obj)

if __name__ == "__main__":
  # Input    
  obj1 = {"a":{"b":{"c":"d"}}}
  key1 = "a/b/c"
  obj2 = {"x":{"y":{"z":"a"}}}
  key2 = "aa/b/d"
  key3 = "x/y/z"
  
  # Print the outputs
  print(get_value_by_key(obj1, key1))

  print(get_value_by_key(obj1, key2))

  print(get_value_by_key(obj2, key3))