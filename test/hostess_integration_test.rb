require 'test_helper'

class HostessIntegrationTest < Test::Unit::TestCase
  
  def test_creating_a_virtual_host
    # Remove our test directory
    FileUtils.rm_rf(Hostess::Test::HOSTESS_TEST_DIR)
    
    # Create our test subdirectories
    FileUtils.mkdir_p(Hostess::Test::APACHE_CONFIG_DIR)
    FileUtils.mkdir_p(Hostess::Test::APACHE_LOG_DIR)
    FileUtils.mkdir_p(Hostess::Test::WEBSITE_DIR)

    # Configure Hostess to use our test directories and to disable sudo
    Hostess.apache_config_dir = Hostess::Test::APACHE_CONFIG_DIR
    Hostess.apache_log_dir    = Hostess::Test::APACHE_LOG_DIR
    Hostess.disable_sudo!
    
    # Ensure the apache config file exists
    FileUtils.touch(Hostess.apache_config)
    
    domain       = 'example.local'
    options      = Hostess::Options.new('create', domain, Hostess::Test::WEBSITE_DIR)
    virtual_host = Hostess::VirtualHost.new(options)
    
    # Assert that we setup the local DNS entry
    virtual_host.expects(:create_dns_entry)
    
    # Assert that we restart apache
    virtual_host.expects(:restart_apache)
    
    virtual_host.execute!
    
    # Assert that we've updated the apache config file correctly
    expected_apache_config_file_content = <<-EOS


# Line added by #{Hostess.script_name}
NameVirtualHost *:80
Include #{File.join(Hostess.vhosts_dir, '*.conf')}
    EOS
    assert_equal expected_apache_config_file_content, File.read(Hostess.apache_config)
    
    # Assert that we've created the hostess vhosts directory
    assert File.directory?(Hostess.vhosts_dir)
    
    # Assert that we've created the hostess log directory
    assert File.directory?(Hostess.vhosts_log_dir)
    
    # Assert that we've create the vhost config
    domain, directory, apache_ = 'example.local', Hostess::Test::WEBSITE_DIR
    expected_vhost_content = <<-EOS
<VirtualHost *:80>
  ServerName #{domain}
  DocumentRoot #{Hostess::Test::WEBSITE_DIR}
  <Directory #{Hostess::Test::WEBSITE_DIR}>
    Options FollowSymLinks
    AllowOverride All
    allow from all
  </Directory>
  <DirectoryMatch "^/.*/\.svn/">
    ErrorDocument 403 /404.html
    Order allow,deny
    Deny from all
    Satisfy All
  </DirectoryMatch>
  ErrorLog #{File.join(Hostess.vhosts_log_dir, domain, 'error_log')}
  CustomLog #{File.join(Hostess.vhosts_log_dir, domain, 'access_log')} common
  #RewriteLogLevel 3
  RewriteLog #{File.join(Hostess.vhosts_log_dir, domain, 'rewrite_log')}
</VirtualHost>
    EOS
    vhost_config_file = File.join(Hostess.vhosts_dir, 'example.local.conf')
    assert File.exists?(vhost_config_file)
    assert_equal expected_vhost_content, File.read(vhost_config_file)
  end
  
end