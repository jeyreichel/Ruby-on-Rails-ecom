atom_feed(:language => I18n.locale, :schema_date => 2009,
          :id => url_for(params.merge({ :only_path => false })),
          :root_url => url_for(params.merge({ :only_path => false, :format => nil })),
          "xmlns:georss" => "http://www.georss.org/georss") do |feed|
  feed.title @title

  feed.subtitle :type => 'xhtml' do |xhtml|
    xhtml.p do |p|
      p << @description
    end
  end

  feed.updated @edits.map {|e|  [e.created_at, e.closed_at].max }.max
  feed.icon "http://#{SERVER_URL}/favicon.ico"
  feed.logo "http://#{SERVER_URL}/images/mag_map-rss2.0.png"

  feed.rights :type => 'xhtml' do |xhtml|
    xhtml.a :href => "http://creativecommons.org/licenses/by-sa/2.0/" do |a|
      a.img :src => "http://#{SERVER_URL}/images/cc_button.png", :alt => "CC by-sa 2.0"
    end
  end

  for changeset in @edits
    feed.entry(changeset, :updated => changeset.closed_at, :id => changeset_url(changeset.id, :only_path => false)) do |entry|
      entry.link :rel => "alternate",
                 :href => changeset_read_url(changeset, :only_path => false),
                 :type => "application/osm+xml"
      entry.link :rel => "alternate",
                 :href => changeset_download_url(changeset, :only_path => false),
                 :type => "application/osmChange+xml"

      entry.title t('browse.changeset.title') + " " + h(changeset.id)

      if changeset.user.data_public?
        entry.author do |author|
          author.name changeset.user.display_name
          author.uri url_for(:controller => 'user', :action => 'view', :display_name => changeset.user.display_name, :only_path => false)
        end
      end

      feed.content :type => 'xhtml' do |xhtml|
        xhtml.style "th { text-align: left } tr { vertical-align: top }"
        xhtml.table do |table|
          table.tr do |tr|
            tr.th t("browse.changeset_details.created_at")
            tr.td l(changeset.created_at)
          end
          table.tr do |tr|
            tr.th t("browse.changeset_details.closed_at")
            tr.td l(changeset.closed_at)
          end
          if changeset.user.data_public?
            table.tr do |tr|
              tr.th t("browse.changeset_details.belongs_to")
              tr.td do |td|
                td.a h(changeset.user.display_name), :href => url_for(:controller => "user", :action => "view", :display_name => changeset.user.display_name, :only_path => false)
              end
            end
          end
          unless changeset.tags.empty?
            table.tr do |tr|
              tr.th t("browse.tag_details.tags")
              tr.td do |td|
                td.table :cellpadding => "0" do |table|
                  changeset.tags.sort.each do |tag|
                    table.tr do |tr|
                      tr.td "#{h(tag[0])} = #{sanitize(auto_link(tag[1]))}"
                    end
                  end
                end
              end
            end
          end
        end
      end

      unless changeset.min_lat.nil?
        minlon = changeset.min_lon/GeoRecord::SCALE.to_f
        minlat = changeset.min_lat/GeoRecord::SCALE.to_f
        maxlon = changeset.max_lon/GeoRecord::SCALE.to_f
        maxlat = changeset.max_lat/GeoRecord::SCALE.to_f

        # See http://georss.org/Encodings#Geometry
        lower_corner = "#{minlat} #{minlon}"
        upper_corner = "#{maxlat} #{maxlon}"

        feed.georss :box, lower_corner + " " + upper_corner
      end
    end
  end
end
