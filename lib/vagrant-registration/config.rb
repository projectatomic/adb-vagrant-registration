require "vagrant"
require "ostruct"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)
      def initialize(region_specific=false)
        @conf = UNSET_VALUE
        @logger = Log4r::Logger.new("vagrant_registration::config")
      end

      def finalize!
        @conf.skip = false unless @conf.skip
        @logger.info "Final registration configuration: #{@conf.inspect}"
      end

      def method_missing(method_sym, *arguments, &block)
        # Don't set this in initialize to preserve config hierarchy
        @conf = OpenStruct.new if @conf == UNSET_VALUE
        command = "@conf.#{method_sym} #{adjust_arguments(arguments)}"
        @logger.info "Evaluating registration configuration: #{command}"
        eval command
      end

      private

        def adjust_arguments(args)
          return '' if args.size < 1
          args.map{|a| a.is_a?(String) ? "'#{a}'" : a}.join(',')
        end
    end
  end
end
