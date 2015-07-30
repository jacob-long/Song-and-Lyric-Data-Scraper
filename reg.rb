require 'rubygems'
require 'gracenote'

spec = {:clientID => "1114112", :clientTag => "D355445DB6F98725614E18EE75361968"}
obj = Gracenote.new(spec)
obj.registerUser

search = obj.findAlbum("Jay-Z", "The Blueprint 3", 0)
puts search.inspect