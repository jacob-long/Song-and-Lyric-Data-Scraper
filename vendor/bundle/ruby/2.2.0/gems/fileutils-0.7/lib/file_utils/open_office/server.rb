module FileUtils::OpenOffice

    module Server

        def self.start
            pid1 = fork do
                exec FileUtils::Config::OpenOffice.xvfb
            end
            sleep 5 # 5 seconden wachten tot xvfb draait
            pid2 = fork do
                exec FileUtils::Config::OpenOffice.command
            end            
        end

        def self.stop
            `#{FileUtils::Config::OpenOffice.stop_xvfb}`
            sleep 5
            `#{FileUtils::Config::OpenOffice.stop}`
        end

        def self.restart
            stop
            sleep 5
            start
        end

    end

end