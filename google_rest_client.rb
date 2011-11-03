require 'uri'

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

  # Takes a URL and returns the location string.
  def get_address(url)
    url = URI.decode(url)
    loc = url.split('loc:+')
    return nil if loc.length == 1
    loc_str = loc[1]
    loc_str.split('+').join(' ')
  end

  private

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