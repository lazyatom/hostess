module Hostess
  class Options
    attr_reader :action, :domain, :directory
    def initialize(action=nil, domain=nil, directory=nil)
      @action, @domain, @directory = action, domain, directory
    end
    def directory
      File.expand_path(@directory) if @directory
    end
    def display_banner_and_return
      puts banner
      exit
    end
    def valid?
      valid_create? or valid_delete? or valid_list? or valid_help?
    end
    private
      def valid_create?
        @action == 'create' and domain and directory
      end
      def valid_delete?
        @action == 'delete' and domain
      end
      def valid_list?
        @action == 'list'
      end
      def valid_help?
        @action == 'help'
      end
      def banner
<<EndBanner
  Usage:
    #{Hostess.script_name} create domain directory - create a new virtual host
    #{Hostess.script_name} delete domain           - delete a virtual host
    #{Hostess.script_name} list                    - list #{Hostess.script_name} virtual hosts
    #{Hostess.script_name} help                    - this info
EndBanner
      end
  end
end