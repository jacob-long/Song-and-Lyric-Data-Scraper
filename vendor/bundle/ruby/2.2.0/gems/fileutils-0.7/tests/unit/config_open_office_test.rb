require File.dirname(__FILE__) + "/../test_helper"

class ConfigOpenOfficeTest < Test::Unit::TestCase

    def test_config_open_office_exists
        assert_nothing_raised do
            FileUtils::Config::OpenOffice
        end
    end

    def setup
        @params = {
            :executable => FileUtils::Config::OpenOffice.executable,
            :host       => FileUtils::Config::OpenOffice.host,
            :port       => FileUtils::Config::OpenOffice.port,
            :params     => FileUtils::Config::OpenOffice.params,
            :xvfb       => FileUtils::Config::OpenOffice.xvfb,
            :stop_xvfb  => FileUtils::Config::OpenOffice.stop_xvfb,
            :stop       => FileUtils::Config::OpenOffice.stop,
            :python     => FileUtils::Config::OpenOffice.python
        }
    end

    # Reset of config
    def teardown
        FileUtils::Config::OpenOffice.executable = @params[:executable] 
        FileUtils::Config::OpenOffice.host       = @params[:host]
        FileUtils::Config::OpenOffice.port       = @params[:port]
        FileUtils::Config::OpenOffice.params     = @params[:params]
        FileUtils::Config::OpenOffice.xvfb       = @params[:xvfb]
        FileUtils::Config::OpenOffice.stop_xvfb  = @params[:stop_xvfb]
        FileUtils::Config::OpenOffice.stop       = @params[:stop]
        FileUtils::Config::OpenOffice.python     = @params[:python]
    end

    def test_config_openoffice_executable
        assert_kind_of String, FileUtils::Config::OpenOffice.executable
        assert_equal 'soffice', FileUtils::Config::OpenOffice.executable
        FileUtils::Config::OpenOffice.executable = 'soffice.exe'
        assert_equal 'soffice.exe', FileUtils::Config::OpenOffice.executable
        FileUtils::Config::OpenOffice.executable = 'soffice'
    end

    def test_config_openoffice_port
        assert_kind_of Integer, FileUtils::Config::OpenOffice.port
        assert_equal 8000, FileUtils::Config::OpenOffice.port
        FileUtils::Config::OpenOffice.port = 8020
        assert_equal 8020, FileUtils::Config::OpenOffice.port
        FileUtils::Config::OpenOffice.port = 8000
    end

    def test_config_openoffice_host
        assert_kind_of String, FileUtils::Config::OpenOffice.host
        assert_equal '127.0.0.1', FileUtils::Config::OpenOffice.host
        FileUtils::Config::OpenOffice.host = 'localhost'
        assert_equal 'localhost', FileUtils::Config::OpenOffice.host
        FileUtils::Config::OpenOffice.host = '127.0.0.1'
    end

    def test_config_openoffice_params
        assert_kind_of String, FileUtils::Config::OpenOffice.params
        assert_equal '-headless -display :30 -accept="socket,host=[host],port=[port];urp;" -nofirststartwizard', FileUtils::Config::OpenOffice.params
        FileUtils::Config::OpenOffice.params = '-headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard'
        assert_equal '-headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard', FileUtils::Config::OpenOffice.params
        FileUtils::Config::OpenOffice.params = '-headless -accept="socket,host=[host],port=[port];urp;" -nofirststartwizard'
    end

    def test_config_openoffice_command
        assert_kind_of String, FileUtils::Config::OpenOffice.command
        assert_equal 'soffice -headless -display :30 -accept="socket,host=127.0.0.1,port=8000;urp;" -nofirststartwizard', FileUtils::Config::OpenOffice.command

        FileUtils::Config::OpenOffice.executable  = 'soffice.exe'
        FileUtils::Config::OpenOffice.host = 'localhost'
        FileUtils::Config::OpenOffice.port = 8080
        FileUtils::Config::OpenOffice.params = '-headless -display :30 -accept="socket,host=[host],port=[port];urp;"'

        assert_equal 'soffice.exe -headless -display :30 -accept="socket,host=localhost,port=8080;urp;"', FileUtils::Config::OpenOffice.command
    end

    def test_config_openoffice_xvfb
        assert_kind_of String, FileUtils::Config::OpenOffice.xvfb
        assert_equal 'Xvfb :30 -screen 0 1024x768x24', FileUtils::Config::OpenOffice.xvfb
        FileUtils::Config::OpenOffice.xvfb = 'Xvfb'
        assert_equal 'Xvfb', FileUtils::Config::OpenOffice.xvfb
    end

    def test_config_openoffice_stop_xvfb
        assert_kind_of String, FileUtils::Config::OpenOffice.stop_xvfb
        assert_equal 'killall -9 Xvfb', FileUtils::Config::OpenOffice.stop_xvfb
        FileUtils::Config::OpenOffice.stop_xvfb = 'echo "dummy"'
        assert_equal 'echo "dummy"', FileUtils::Config::OpenOffice.stop_xvfb
    end

    def test_config_openoffice_stop
        assert_kind_of String, FileUtils::Config::OpenOffice.stop
        assert_equal 'killall -9 soffice.bin', FileUtils::Config::OpenOffice.stop
        FileUtils::Config::OpenOffice.stop = 'echo "dummy"'
        assert_equal 'echo "dummy"', FileUtils::Config::OpenOffice.stop
    end

    def test_config_openoffice_python
        assert_kind_of String, FileUtils::Config::OpenOffice.python
        assert_equal 'python', FileUtils::Config::OpenOffice.python
        FileUtils::Config::OpenOffice.python = '/usr/bin/python'
        assert_equal '/usr/bin/python', FileUtils::Config::OpenOffice.python 
    end

end