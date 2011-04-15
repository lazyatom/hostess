require 'test_helper'

class HostessIntegrationTest < Test::Unit::TestCase
  
  def test_creating_a_virtual_host
    Hostess.apache_config_dir = File.join(Dir.tmpdir, 'hostess', 'apache_config')
    Hostess.apache_log_dir    = File.join(Dir.tmpdir, 'hostess', 'apache_logs')
    Hostess.disable_sudo!
    
    create_hostess_directories_and_apache_config
    
    domain, path_to_site = 'example.local', '/path/to/site'
    options      = Hostess::Options.new('create', domain, path_to_site)
    virtual_host = Hostess::VirtualHost.new(options)
    
    ensure_we_setup_the_local_dns_entry(virtual_host)
    ensure_we_restart_apache(virtual_host)
    
    virtual_host.execute!

    assert_that_we_have_updated_the_apache_config_file
    assert_that_we_have_created_the_hostess_vhosts_directory
    assert_that_we_have_created_the_hostess_log_directory
    assert_that_we_have_created_the_vhost(domain, path_to_site)
  end
  
  private
  
    def create_hostess_directories_and_apache_config
      # Remove our test directories and apache config
      FileUtils.rm_f(Hostess.apache_config_dir)
      FileUtils.rm_f(Hostess.apache_log_dir)
      FileUtils.rm_f(Hostess.apache_config)

      # Create our test subdirectories and apache config
      FileUtils.mkdir_p(Hostess.apache_config_dir)
      FileUtils.mkdir_p(Hostess.apache_log_dir)
      FileUtils.touch(Hostess.apache_config)
    end
  
    def ensure_we_setup_the_local_dns_entry(virtual_host)
      virtual_host.expects(:create_dns_entry)
    end
    
    def ensure_we_restart_apache(virtual_host)
      virtual_host.expects(:restart_apache)
    end
    
    def assert_that_we_have_updated_the_apache_config_file
      expected_apache_config_file_content = <<-EOS


# Line added by #{Hostess.script_name}
NameVirtualHost *:80
Include #{File.join(Hostess.vhosts_dir, '*.conf')}
      EOS
      assert_equal expected_apache_config_file_content, File.read(Hostess.apache_config)
    end
    
    def assert_that_we_have_created_the_hostess_vhosts_directory
      assert File.directory?(Hostess.vhosts_dir)
    end
    
    def assert_that_we_have_created_the_hostess_log_directory
      assert File.directory?(Hostess.vhosts_log_dir)
    end
    
    def assert_that_we_have_created_the_vhost(domain, path_to_site)
      expected_vhost_content = <<-EOS
<VirtualHost *:80>
  ServerName #{domain}
  DocumentRoot "#{path_to_site}"
  <Directory "#{path_to_site}">
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
      assert_equal expected_vhost_content, File.read(File.join(Hostess.vhosts_dir, "#{domain}.conf"))
    end
  
end