require "vagrant"
require "ostruct"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)
      attr_reader :conf

      def initialize(region_specific=false)
        @conf = UNSET_VALUE
        @logger = Log4r::Logger.new("vagrant_registration::config")
      end

      def finalize!
        get_config
        @conf.skip = false unless @conf.skip
        # Unregister on halt by default
        @conf.unregister_on_halt = true if @conf.unregister_on_halt.nil?
        @logger.info "Final registration configuration: #{@conf.inspect}"
      end

      def method_missing(method_sym, *arguments, &block)
        get_config
        command = "@conf.#{method_sym} #{adjust_arguments(arguments)}"
        @logger.info "Evaluating registration configuration: #{command}"
        eval command
      end

      private

        # Don't set @conf to OpenStruct in initialize
        # to preserve config hierarchy
        def get_config
          @conf = OpenStruct.new if @conf == UNSET_VALUE
        end

        def adjust_arguments(args)
          return '' if args.size < 1
          args.map{|a| a.is_a?(String) ? "'#{a}'" : a}.join(',')
        end
    end
  end
end
