module Hostess
  class VirtualHost
    def initialize(options, debug=false)
      @options, @debug = options, debug
    end
    def execute!
      __send__(@options.action)
    end
    def create
      setup_apache_config
      create_vhost_directory
      create_apache_log_directory
      create_dns_entry
      create_vhost
      restart_apache
    end
    def delete
      delete_dns_entry
      delete_vhost
      delete_apache_log_directory
      restart_apache
    end
    def list
      Dir[File.join(Hostess.vhosts_dir, '*.conf')].each do |config_file|
        puts File.basename(config_file, '.conf')
      end
    end
    def help
      @options.display_banner_and_return
    end
    private
      def dscl_works?
        `sw_vers -productVersion`.strip < '10.7'
      end
      def hosts_filename
        File.join('/', 'etc', 'hosts')
      end
      def create_dns_entry
        if dscl_works?
          run "dscl localhost -create /Local/Default/Hosts/#{@options.domain} IPAddress 127.0.0.1"
        else
          run "echo '127.0.0.1 #{@options.domain}' >> #{hosts_filename}"
        end
      end
      def delete_dns_entry
        if dscl_works?
          run "dscl localhost -delete /Local/Default/Hosts/#{@options.domain}"
        else
          run "perl -pi -e 's/127.0.0.1 #{@options.domain}\\n//g' #{hosts_filename}"
        end
      end
      def create_vhost
        tempfile = Tempfile.new('vhost')
        tempfile.puts(vhost_config)
        tempfile.close
        run "mv #{tempfile.path} #{config_filename}"
      end
      def delete_vhost
        run "rm #{config_filename}"
      end
      def apache_log_directory
        File.join(Hostess.vhosts_log_dir, @options.domain)
      end
      def create_apache_log_directory
        run "mkdir -p #{apache_log_directory}"
      end
      def delete_apache_log_directory
        run "rm -r #{apache_log_directory}"
      end
      def vhost_config
        domain, directory = @options.domain, @options.directory
        template = <<-EOT
<VirtualHost *:80>
  ServerName <%= domain %>
  DocumentRoot "<%= directory %>"
  <Directory "<%= directory %>">
    Require all granted
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
        File.join(Hostess.vhosts_dir, "#{@options.domain}.conf")
      end
      def setup_apache_config
        unless File.read(Hostess.apache_config).include?("Include #{File.join(Hostess.vhosts_dir, '*.conf')}")
          run "echo '' >> #{Hostess.apache_config}"
          run "echo '' >> #{Hostess.apache_config}"
          run "echo '# Line added by #{Hostess.script_name}' >> #{Hostess.apache_config}"
          run "echo 'NameVirtualHost *:80' >> #{Hostess.apache_config}"
          run "echo 'Include #{File.join(Hostess.vhosts_dir, '*.conf')}' >> #{Hostess.apache_config}"
        end
      end
      def create_vhost_directory
        run "mkdir -p #{Hostess.vhosts_dir}"
      end
      def restart_apache
        run "apachectl restart"
      end
      def run(cmd)
        cmd = sudo(cmd) if Hostess.use_sudo?
        puts cmd if @debug
        system cmd
      end
      def sudo(cmd)
         "sudo -s \"#{cmd}\""
      end
  end
end
