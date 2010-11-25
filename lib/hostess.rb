require 'erb'
require 'fileutils'
require 'pathname'

module Hostess
  SCRIPT              = File.basename($0)
  APACHE_CONFIG_DIR   = Pathname.new('/') + 'etc' + 'apache2'
  APACHE_CONFIG       = APACHE_CONFIG_DIR + 'httpd.conf'
  VHOSTS_DIR          = APACHE_CONFIG_DIR + "#{SCRIPT}_vhosts"
  APACHE_LOG_DIR      = Pathname.new('/') + 'var' + 'log' + 'apache2'
  VHOSTS_LOG_DIR      = APACHE_LOG_DIR    + "#{SCRIPT}_vhosts"
  
  autoload :Options,     'hostess/options'
  autoload :VirtualHost, 'hostess/virtual_host'
end