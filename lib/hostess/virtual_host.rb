module Hostess
  class VirtualHost
    def initialize(options)
      @options = options
    end
    def execute!
      __send__(@options.action)
    end
    def create
      warn_and_return unless sudoer?
      setup_apache_config
      create_vhost_directory
      create_apache_log_directory
      system "dscl localhost -create /Local/Default/Hosts/#{@options.domain} IPAddress 127.0.0.1"
      File.open(config_filename, 'w') { |f| f.puts(vhost_config) }
      restart_apache
    end
    def delete
      warn_and_return unless sudoer?
      system "dscl localhost -delete /Local/Default/Hosts/#{@options.domain}"
      File.delete(config_filename)
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
        File.expand_path(File.join('~', "." + SCRIPT, 'log', @options.domain))
      end
      def create_apache_log_directory
        FileUtils.mkdir_p(apache_log_directory)
      end
      def warn_and_return
        puts "Please use sudo to use this utility to create or delete virtual hosts"
        exit
      end
      def sudoer?
        # A proxy for actually knowing whether or not the user has all required privileges
        File.stat(APACHE_CONFIG).writable?
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
          File.open(APACHE_CONFIG, 'a') do |file|
            file.puts ""
            file.puts ""
            file.puts "# Line added by #{SCRIPT}"
            file.puts "NameVirtualHost *:80"
            file.puts "Include #{File.join(VHOSTS_DIR, '*.conf')}"
          end
        end
      end
      def create_vhost_directory
        FileUtils.mkdir_p(VHOSTS_DIR)
      end
      def restart_apache
        `apachectl restart`
      end
  end
end