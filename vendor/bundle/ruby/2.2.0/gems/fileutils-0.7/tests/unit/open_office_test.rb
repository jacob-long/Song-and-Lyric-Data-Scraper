require File.dirname(__FILE__) + "/../test_helper"

class OpenOfficeTest < Test::Unit::TestCase

    def test_open_office_exists
        assert_nothing_raised do
            FileUtils::OpenOffice
        end
    end

    def test_open_office_convert
        assert_nothing_raised do
            path = '/tmp/test.pdf'
            File.delete(path) if File.exists?(path) && File.writable?(path)
            FileUtils::OpenOffice.convert File.dirname(__FILE__) + "/../helpers/test.odt", path
            assert File.exists?(path), 'Pdf bestaat niet'
        end
    end

    def test_open_office_convert_stream
        assert_nothing_raised do
            content = IO.read(File.dirname(__FILE__) + "/../helpers/test.odt")
            assert_kind_of String, FileUtils::OpenOffice.convert(content, 'odt', 'pdf') 
        end
    end

end