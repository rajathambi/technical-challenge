import unittest
import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from deep_get import get_value_by_key

class CheckGetValueByKey(unittest.TestCase):
  """Test Class for Get Value by Key function

  Args:
      unittest (_type_): unittest framework class
  """  
  def test_retrun_value_as_string(self):
    """Test result should be string format
    """      
    nested_obj = {"a":{"b":{"c":"d"}}}
    key = "a/b/c"  
    result = get_value_by_key(nested_obj, key)  
    self.assertEqual(result, "d", "Return value should be string") 
    
  def test_return_value_as_dict(self):
    """Test result should be Dict format
    """       
    nested_obj = {"a":{"b":{"c":{"d":"e"}}}}
    key = "a/b/c"  
    result = get_value_by_key(nested_obj, key)  
    self.assertEqual(result, {"d":"e"}, "Return value should be dict")
    
  def test_retrun_value_as_none(self):
    """Test result should be None
    """      
    json_obj = {"a":{"b":{"c":"d"}}}
    key = "a.b.c"  
    result = get_value_by_key(json_obj, key)  
    self.assertEqual(result, None, "Return value should be string")  
  
if __name__ == '__main__':  
    unittest.main()