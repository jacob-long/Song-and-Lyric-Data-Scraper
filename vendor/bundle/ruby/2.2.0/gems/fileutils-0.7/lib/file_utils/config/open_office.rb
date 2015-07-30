module FileUtils::Config

    module OpenOffice

        def self.command
            "#{executable} #{parsed_params}"
        end

        def self.parsed_params
            params.gsub('[port]', port.to_s).gsub('[host]', host)
        end

        def self.executable
            @openoffice ||= "soffice"
        end

        def self.executable= (openoffice)
            @openoffice = openoffice
        end

        def self.port
            @port ||= 8000
        end

        def self.port= (port)
            @port = port
        end

        def self.host
            @host ||= "127.0.0.1"
        end

        def self.host= (host)
             @host = host
        end

        def self.params
            @params ||= '-headless -display :30 -accept="socket,host=[host],port=[port];urp;" -nofirststartwizard'
        end

        def self.params= (params)
            @params = params
        end

        def self.xvfb
            @xvfb ||= 'Xvfb :30 -screen 0 1024x768x24'
        end

        def self.xvfb= (xvfb)
            @xvfb = xvfb
        end

        def self.stop_xvfb
            @stop_xvfb ||= 'killall -9 Xvfb'
        end

        def self.stop_xvfb= (stop_xvfb)
            @stop_xvfb = stop_xvfb
        end

        def self.stop
            @stop ||= 'killall -9 soffice.bin'
        end

        def self.stop= (stop)
            @stop = stop
        end

        def self.python
            @python ||= 'python'
        end

        def self.python= (python)
            @python = python
        end

    end

end