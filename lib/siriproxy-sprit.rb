# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'eat'
require 'nokogiri'
require 'timeout'


#######
#
# This is simple plugin which shows the cheapest gasstations in Austria on the Map
#
#       Remember to put this plugins into the "./siriproxy/config.yml" file 
#######
#
# Diese plugin zeigt die billigsten Tankstellen(Österreich) in deiner Nähe auf der Map.
# 
#      ladet das Plugin in der "./siriproxy/config.yml" datei !
#
#######
## ##  WIE ES FUNKTIONIERT 
#
# sagt "ich/wo" + "Benzin/Diesel tanken" 
#
# bei Fragen Twitter: @muhkuh0815
# oder github.com/muhkuh0815/siriproxy-sprit
# Video ---
#
#
#### ToDo
#
#  -
#
#######


class SiriProxy::Plugin::Sprit < SiriProxy::Plugin
    
    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    def doc
    end
    def busi
    end
    def empl
    end
    def location()
    lat1 = $mapla - 0.01
    lat2 = $mapla + 0.01
    lon1 = $maplo - 0.01
    lon2 = $maplo + 0.01
      
    return lat1.round(5), lon1.round(5), lat2.round(5), lon2.round(5)
    end
    
    filter "SetRequestOrigin", direction: :from_iphone do |object|
    	puts "[Info - User Location] lat: #{object["properties"]["latitude"]}, long: #{object["properties"]["longitude"]}"
    	$maplo = object["properties"]["longitude"]
    	$mapla = object["properties"]["latitude"]
    end 
    
    def read(art)
      loc = location()
      lat1 = loc[0]
      lon1 = loc[1]
      lat2 = loc[2]
      lon2 = loc[3]
      print "box 1:" + lat1.to_s + "," + lon1.to_s + " :2: " + lat2.to_s + "," + lon2.to_s
      @shaf = ""
      begin
	if art == "D"
	  dos = "http://www.spritpreisrechner.at/espritmap-app/GasStationServlet?data=[\"\",\"DIE\"," + lon1.to_s + "," + lat1.to_s + "," + lon2.to_s + "," + lat2.to_s + "]"
	else
	  dos = "http://www.spritpreisrechner.at/espritmap-app/GasStationServlet?data=[\"\",\"SUP\"," + lon1.to_s + "," + lat1.to_s + "," + lon2.to_s + "," + lat2.to_s + "]"
	end
	dos = URI.parse(URI.encode(dos))
	doc = Nokogiri::HTML(open(dos))
	doc.encoding = 'utf-8'
	doc = doc.text
      rescue Timeout::Error
	print "Timeout-Error beim Lesen der Seite"
	@shaf = "timeout"
      rescue
	print "Lesefehler !"
	@shaf = "timeout"
      end
      dat = doc
      return dat
    end
    def conv(string)
  new_string = string.gsub(/Ã¤|Ã|Ã¶|Ã|Ã¼|Ã|Ã/) do |umlaut|
    case umlaut
    when 'Ã¤' then 'ä'
    when 'Ã' then 'Ä'
    when 'Ã¶' then 'ö'
    when 'Ã' then 'Ö'
    when 'Ã¼' then 'ü'
    when 'Ã' then 'Ü'
    when 'Ã' then 'ß'
    end
  end
  return new_string
end
    
listen_for /(ich|wo).*(benzin)/i do
    @shaf = ""
    doc = read("S")
    if doc == NIL 
      say "Keine Daten vorhanden!"
    else
      busi = Array.new
      empl = JSON.parse(doc)
      busi = empl.to_a
      add_views = SiriAddViews.new
      add_views.make_root(last_ref_id)
      map_snippet = SiriMapItemSnippet.new(true)
      z = 0
      busi.each do |data|
	if data["spritPrice"].first["amount"] == ""
	else
	  preis = data["spritPrice"].first["amount"]
	  lat = data["latitude"]
	  lon = data["longitude"]
	  adr = conv(data["address"])
	  city = data["city"]
	  post = data["postalCode"]
	  sname = "S:" + preis.to_s + " " + conv(data["gasStationName"]).to_s
	  siri_location = SiriLocation.new(sname, adr.to_s, post.to_s,"9", "AT", city.to_s , lat.to_s , lon.to_s)
	  map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
	  z += 1
	end
      end
      say "", spoken: "Hier die " + z.to_s + " billigsten Tankstellen in deiner Naehe"
      utterance = SiriAssistantUtteranceView.new("")
      add_views.views << utterance
      add_views.views << map_snippet
      send_object add_views 
    end  
    request_completed
end

listen_for /(ich|wo).*(Diesel)/i do
    @shaf = ""
    doc = read("D")
    if doc == NIL 
      say "Keine Daten vorhanden!"
    else
      busi = Array.new
      empl = JSON.parse(doc)
      busi = empl.to_a
      add_views = SiriAddViews.new
      add_views.make_root(last_ref_id)
      map_snippet = SiriMapItemSnippet.new(true)
      z = 0
      busi.each do |data|
	if data["spritPrice"].first["amount"] == ""
	else
	  preis = data["spritPrice"].first["amount"]
	  lat = data["latitude"]
	  lon = data["longitude"]
	  adr = conv(data["address"])
	  city = data["city"]
	  post = data["postalCode"]
	  sname = "D:" + preis.to_s + " " + conv(data["gasStationName"]).to_s
	  siri_location = SiriLocation.new(sname, adr.to_s, post.to_s,"9", "AT", city.to_s , lat.to_s , lon.to_s)
	  map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
	  z += 1
	end
      end
      say "", spoken: "Hier die " + z.to_s + " billigsten Tankstellen in deiner Naehe"
      utterance = SiriAssistantUtteranceView.new("")
      add_views.views << utterance
      add_views.views << map_snippet
      send_object add_views 
    end  
    request_completed
end

end
