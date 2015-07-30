module FileUtils

    module Config

        def self.tmp_dir
            @tmp_dir ||= '/tmp'
        end

        def self.tmp_dir= (tmp_dir)
            @tmp_dir = tmp_dir
        end

        def self.pdftk
            @pdftk ||= 'pdftk'
        end

        def self.pdftk= (pdftk)
            @pdftk = pdftk
        end

        def self.zip
            @zip ||= 'zip'
        end

        def self.zip= (zip)
            @zip = zip
        end

        autoload :OpenOffice,   File.dirname(__FILE__) + "/config/open_office"
        autoload :Xvfb,         File.dirname(__FILE__) + "/config/xvfb"

    end

end