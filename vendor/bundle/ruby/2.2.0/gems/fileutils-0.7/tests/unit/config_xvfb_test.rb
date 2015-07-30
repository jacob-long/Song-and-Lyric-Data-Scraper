require File.dirname(__FILE__) + "/../test_helper"

class ConfigXvfbTest < Test::Unit::TestCase

    def test_config_xvfb_exists
        assert_nothing_raised do
            FileUtils::Config::Xvfb
        end
    end

    def teardown
        FileUtils::Config::Xvfb.executable = 'xvfb-run'
        FileUtils::Config::Xvfb.params = '--server-args="-screen 0, 1024x768x24"'
    end

    def test_config_xvbf_executable
        assert_kind_of String, FileUtils::Config::Xvfb.executable
        assert_equal 'xvfb-run', FileUtils::Config::Xvfb.executable
        FileUtils::Config::Xvfb.executable = '/usr/bin/xvfb-run'
        assert_equal '/usr/bin/xvfb-run', FileUtils::Config::Xvfb.executable
    end

    def test_config_xvfb_params
        assert_kind_of String, FileUtils::Config::Xvfb.params
        assert_equal '--server-args="-screen 0, 1024x768x24"', FileUtils::Config::Xvfb.params
        FileUtils::Config::Xvfb.params = 'dummy'
        assert_equal 'dummy', FileUtils::Config::Xvfb.params
    end

    def test_config_xvfb_command
        assert_equal 'xvfb-run --server-args="-screen 0, 1024x768x24" echo "test"', FileUtils::Config::Xvfb.command('echo "test"')
    end
        
end