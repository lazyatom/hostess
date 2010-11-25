module Hostess
  class VirtualHost
    def initialize(options)
      @options = options
    end
    def execute!
      __send__(@options.action)
    end
    def create
      setup_apache_config
      create_vhost_directory
      create_apache_log_directory
      sudo "dscl localhost -create /Local/Default/Hosts/#{@options.domain} IPAddress 127.0.0.1"
      tempfile = Tempfile.new('vhost')
      tempfile.puts(vhost_config)
      tempfile.close
      sudo "mv #{tempfile.path} #{config_filename}"
      restart_apache
    end
    def delete
      sudo "dscl localhost -delete /Local/Default/Hosts/#{@options.domain}"
      sudo "rm #{config_filename}"
      restart_apache
    end
    def list
      Dir[File.join(VHOSTS_DIR, '*.conf')].each do |config_file|
        puts File.basename(config_file, '.conf')
      end
    end
    def help
      @options.display_banner_and_return
    end
    private
      def apache_log_directory
        File.join(VHOSTS_LOG_DIR, @options.domain)
      end
      def create_apache_log_directory
        sudo "mkdir -p #{apache_log_directory}"
      end
      def vhost_config
        domain, directory = @options.domain, @options.directory
        template = <<-EOT
<VirtualHost *:80>
  ServerName <%= domain %>
  DocumentRoot <%= directory %>
  <Directory <%= directory %>>
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
  ErrorLog <%= File.join(apache_log_directory, 'error_log') %>
  CustomLog <%= File.join(apache_log_directory, 'access_log') %> common
  #RewriteLogLevel 3
  RewriteLog <%= File.join(apache_log_directory, 'rewrite_log') %>
</VirtualHost>
        EOT
        ERB.new(template).result(binding)
      end
      def config_filename
        File.join(VHOSTS_DIR, "#{@options.domain}.conf")
      end
      def setup_apache_config
        unless File.read(APACHE_CONFIG).include?("Include #{File.join(VHOSTS_DIR, '*.conf')}")
          sudo "echo '' >> #{APACHE_CONFIG}"
          sudo "echo '' >> #{APACHE_CONFIG}"
          sudo "echo '# Line added by #{SCRIPT}' >> #{APACHE_CONFIG}"
          sudo "echo 'NameVirtualHost *:80' >> #{APACHE_CONFIG}"
          sudo "echo 'Include #{File.join(VHOSTS_DIR, '*.conf')}' >> #{APACHE_CONFIG}"
        end
      end
      def create_vhost_directory
        sudo "mkdir -p #{VHOSTS_DIR}"
      end
      def restart_apache
        sudo "apachectl restart"
      end
      def sudo(cmd)
        sudo_cmd = "sudo -s \"#{cmd}\""
        puts sudo_cmd if $DEBUG
        system sudo_cmd
      end
  end
end