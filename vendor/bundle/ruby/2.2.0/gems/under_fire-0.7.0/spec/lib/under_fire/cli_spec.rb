require_relative '../../spec_helper'
require 'rr'

module UnderFire
  describe CLI do
    before do
      @cli = CLI.new
      @stdout_old = $stdout
      @stdin_old = $stdin
      $stdout = StringIO.new
      $stdin = StringIO.new
  end

  after do
    $stdout = @stdout_old
    $stdin = @stdin_old
  end

    # describe "#register" do
    #   before do
    #     response_body = '<RESPONSES><RESPONSE STATUS="OK"><USER>user_id_string</USER></RESPONSE><RESPONSES>'
    #     stub_request(:post, "https://c.web.cddbp.net/webapi/xml/1.0/").
    #       with(:body => "<QUERIES><QUERY cmd=\"REGISTER\"><CLIENT></CLIENT></QUERY></QUERIES>",
    #            :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/xml', 'User-Agent'=>'Ruby'}).
    #       to_return(:status => 200, :body => response_body, :headers => {})
    #     stub.proxy(APIResponse).new(response_body) do |res|
    #       stub(res).success? { true }
    #       stub(res).to_h { { :response => { :user => "adfadsfasa-aq34rqfafafsfdasf"}}}
    #     end
    #   end

    #   it "works" do
    #     mock($stdout).puts "\nIn order to proceed, please obtain a Gracenote Client ID."
    #     mock($stdout).puts "\nTo obtain a Client ID:"
    #     mock($stdout).puts " 1) Register at http://developer.gracenote.com."
    #     mock($stdout).puts " 2) Click on Add a New App."
    #     mock($stdout).puts " 3) Obtain your 'Client ID for Mobile Client, Web API, and eyeQ'"
    #     mock($stdout).puts " from the App Details."
    #     mock($stdout).print "\nPlease press [Enter] once you have a Client ID. "
    #     mock($stdout).print "Enter your client id: "
    #     mock($stdin).gets {"2352352452454"}
    #     mock($stdin).gets
    #     mock($stdout).puts "Saved client_id to /home/jason/.ufrc"
    #     mock($stdout).puts "Saved user_id to /home/jason/.ufrc"
    #     @cli.register
    #   end
    # end
  end
end
