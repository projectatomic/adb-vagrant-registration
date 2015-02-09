module VagrantPlugins
  module GuestRedHat
    module Cap
      class ContainerProbeTool
        def self.container_probe_tool(machine)
          machine.communicate.test("/usr/bin/container-probe-tool", sudo: true)
        end
      end
    end
  end
end
