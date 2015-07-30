module FileUtils::Config

    module Xvfb

        def self.executable
            @executable ||= "xvfb-run"
        end

        def self.executable= (executeable)
            @executable = executeable
        end

        def self.params
            @params ||= '--server-args="-screen 0, 1024x768x24"'
        end

        def self.params= (params)
            @params = params
        end

        def self.command (subcommand)
            "#{executable} #{params} #{subcommand}"
        end

    end

end