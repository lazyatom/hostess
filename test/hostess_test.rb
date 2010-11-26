require 'test_helper'

class HostessTest < Test::Unit::TestCase
  
  def test_should_set_a_default_for_the_apache_config_directory
    Hostess.apache_config_dir = nil
    
    assert_equal '/etc/apache2', Hostess.apache_config_dir
  end
  
  def test_should_allow_us_to_override_the_default_apache_config_directory
    Hostess.apache_config_dir = '/path/to/apache'
    
    assert_equal '/path/to/apache', Hostess.apache_config_dir
  end
  
  def test_should_return_the_path_to_the_apache_config_file
    Hostess.apache_config_dir = '/path/to/apache'
    
    assert_equal '/path/to/apache/httpd.conf', Hostess.apache_config
  end
  
  def test_should_return_the_path_to_vhosts_directory
    Hostess.apache_config_dir = '/path/to/apache'
    
    assert_equal '/path/to/apache/hostess_vhosts', Hostess.vhosts_dir
  end
  
  def test_should_set_a_default_for_the_apache_log_directory
    Hostess.apache_log_dir = nil
    
    assert_equal '/var/log/apache2', Hostess.apache_log_dir
  end
  
  def test_should_allow_us_to_override_the_default_apache_log_directory
    Hostess.apache_log_dir = '/path/to/apache/logs'
    
    assert_equal '/path/to/apache/logs', Hostess.apache_log_dir
  end
  
  def test_should_return_the_path_to_the_vhosts_log_directory
    Hostess.apache_log_dir = '/path/to/apache/logs'
    
    assert_equal '/path/to/apache/logs/hostess_vhosts', Hostess.vhosts_log_dir
  end
  
  def test_should_use_sudo_by_default
    # Have to ensure that we haven't disabled sudo
    Hostess.instance_variable_set("@disable_sudo", false)
    
    assert_equal true, Hostess.use_sudo?
  end
  
  def test_should_allow_us_to_disable_sudo
    Hostess.disable_sudo!
    
    assert_equal false, Hostess.use_sudo?
  end
  
end