require 'rubygems'
require 'mechanize'
require 'yaml'
require 'restclient'
require 'json'

require File.expand_path('../google_rest_client.rb', __FILE__)

module CraigScraper

  # Actual mechanized scraping.
  class Scraper

    def initialize(url)
      @@ignore = YAML.load_file('config.yaml')['ignore']

      @num_coordinates = 0
      @num_total = 0

      @@agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
      @@rest_client = GoogleRestClient.new
      @url = url
    end

    def output(text, href, address)
      puts "#{text} (#{href}): #{address}"
    end

    def get_map_link(link)
      href = link.href
      @@agent.get(href) do |page|
        page.links.each do |l|
          next unless l.text == 'google map'
          address = @@rest_client.get_address(l.href)
          output(link.text, href, address)
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