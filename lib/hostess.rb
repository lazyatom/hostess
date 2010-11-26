require 'erb'
require 'fileutils'
require 'pathname'
require 'tempfile'

module Hostess
  
  autoload :Options,     'hostess/options'
  autoload :VirtualHost, 'hostess/virtual_host'
  
  class << self
    
    attr_writer :apache_config_dir, :apache_log_dir
    
    def script_name
      'hostess'
    end
    
    def apache_config_dir
      @apache_config_dir || File.join('/', 'etc', 'apache2')
    end
    
    def apache_config
      File.join(apache_config_dir, 'httpd.conf')
    end
    
    def vhosts_dir
      File.join(apache_config_dir, "#{script_name}_vhosts")
    end
    
    def apache_log_dir
      @apache_log_dir || File.join('/', 'var', 'log', 'apache2')
    end
    
    def vhosts_log_dir
      File.join(apache_log_dir, "#{script_name}_vhosts")
    end
    
    def disable_sudo!
      @disable_sudo = true
    end
    
    def use_sudo?
      @disable_sudo ? false : true
    end
    
  end
  
end