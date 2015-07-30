require File.dirname(__FILE__) + "/../test_helper"

class ConfigTest < Test::Unit::TestCase

    def test_config_exists
        assert_nothing_raised do
            FileUtils::Config
        end
    end

    def test_config_tmp_dir
        tmp_dir = '/tmp'
        assert_equal tmp_dir, FileUtils::Config.tmp_dir
        FileUtils::Config.tmp_dir = '/home/test/tmp'
        assert_equal '/home/test/tmp', FileUtils::Config.tmp_dir
        FileUtils::Config.tmp_dir = tmp_dir
    end

    def test_config_pdftk
        pdftk = 'pdftk'
        assert_equal pdftk, FileUtils::Config.pdftk
        assert_equal 'pdftk', FileUtils::Config.pdftk
        FileUtils::Config.pdftk = '/usr/bin/pdftk'
        assert_equal '/usr/bin/pdftk', FileUtils::Config.pdftk
        FileUtils::Config.pdftk = pdftk
    end

    def test_config_zip
        zip = 'zip'
        assert_equal 'zip', FileUtils::Config.zip
        FileUtils::Config.zip = '/usr/bin/zip'
        assert_equal '/usr/bin/zip', FileUtils::Config.zip
        FileUtils::Config.zip = zip
    end

end