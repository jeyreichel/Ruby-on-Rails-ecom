xml.instruct!

xml.rss("version" => "2.0", 
        "xmlns:geo" => "http://www.w3.org/2003/01/geo/wgs84_pos#",
        "xmlns:georss" => "http://www.georss.org/georss") do
  xml.channel do
    xml.title "OpenStreetBugs"
    xml.description t('bugs.rss.description_area', :min_lat => @min_lat, :min_lon => @min_lon, :max_lat => @max_lat, :max_lon => @max_lon )
    xml.link url_for(:controller => "site", :action => "index", :only_path => false)

    xml << render(:partial => "bug", :collection => @bugs)
  end
end
