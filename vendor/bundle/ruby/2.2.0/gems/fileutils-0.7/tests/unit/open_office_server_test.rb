require File.dirname(__FILE__) + "/../test_helper"

class OpenOfficeServerTest < Test::Unit::TestCase

    def test_openoffice_server_exists
        assert_nothing_raised do
            FileUtils::OpenOffice::Server
        end
    end

end