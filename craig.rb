require 'rubygems'
require 'mechanize'
require 'yaml'
require 'restclient'
require 'uri'
require 'json'

module CraigScraper

  # This talks to the Google Geocoding API and parses the JSON.
  class GoogleRestClient

    # main api method
    def get_coordinates(url)

      # get the address
      address = get_address(url)
      return nil if address == nil

      # make a request to the geocoder api
      geodecode(address)
    end


    private

    # Takes a URL and returns the location string.
    def get_address(url)
      url = URI.decode(url)
      loc = url.split('loc:+')
      return nil if loc.length == 1
      loc_str = loc[1]
    end

    # get rest API url.
    def get_geocode_url(address)
      "http://maps.googleapis.com/maps/api/geocode/json?address=" +
      address + "&sensor=true"
    end

    # hits google's geocoding api and returns struct coordinates.
    def geodecode(address)
      begin
        url = get_geocode_url(address)
        response = RestClient.get url
        json = JSON.parse(response)
        location = json['results'][0]['geometry']['location']
        return "#{location['lat']}, #{location['lng']}"
      rescue
        return nil
      end
    end
  end

  # Actual mechanized scraping.
  class Scraper

    def initialize(url)
      @@ignore = ["", "help", "post", "new york craigslist", "housing", "rooms & shares", "all new york", "manhattan", "brooklyn", "queens", "bronx", "staten island", "new jersey", "long island", "westchester", "fairfield", "NYC's worst landlords", "\"foreclosure rescue\" fraud alert", "housing forum", "stating a discriminatory preference in a housing post is illegal", "dial 2-1-1 for social services", "AVOIDING SCAMS & FRAUD", "PERSONAL SAFETY TIPS", "craigslist {tv}", "unofficial flagging faq", "craigslist blog", "success story?"]

      @num_coordinates = 0
      @num_total = 0

      @@agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
      @@rest_client = GoogleRestClient.new
      @url = url
    end

    def get_map_link(link)
      href = link.href
      @@agent.get(href) do |page|
        page.links.each do |l|
          next unless l.text == 'google map'
          coordinates = @@rest_client.get_coordinates(l.href)
          if coordinates
            @num_coordinates += 1
            puts "#{link.text} (#{link.href}): #{coordinates}"
          else
            puts "#{link.text} (#{link.href}): #{l.href}"
            @num_total += 1
          end
        end
      end
    end

    def get_links()
      i = 0
      @@agent.get(@url) do |page|
        page.links.each do |link|
          next if @@ignore.include? link.text
          return if i == 100
          #puts "[#{i}] Checking listing #{link.text}"
          get_map_link(link)
          i += 1
        end
      end
    end
  end
end