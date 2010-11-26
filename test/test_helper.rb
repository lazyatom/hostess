require 'test/unit'
require 'mocha'

require 'hostess'

require 'tmpdir'

module Hostess
  class Test
    HOSTESS_TEST_DIR  = File.join(Dir.tmpdir, 'hostess')
  
    APACHE_CONFIG_DIR = File.join(HOSTESS_TEST_DIR, 'apache_config')
    APACHE_LOG_DIR    = File.join(HOSTESS_TEST_DIR, 'apache_logs')
  
    WEBSITE_DIR       = File.join(HOSTESS_TEST_DIR, 'sites')
  end
end