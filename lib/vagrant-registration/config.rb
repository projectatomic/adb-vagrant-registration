require "vagrant"
require "ostruct"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)

      def initialize(region_specific=false)
        @conf = OpenStruct.new
        @logger = Log4r::Logger.new("vagrant_registration::config")
      end

      def finalize!
        @conf.force = true unless @conf.force
        @conf.skip = false unless @conf.skip
        @conf.auto_attach = true unless @conf.auto_attach
        @logger.info "Final registration configuration: #{@conf.inspect}"
      end

      def method_missing(method_sym, *arguments, &block)
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
