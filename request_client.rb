#!/usr/bin/ruby
#
# Aurora coding challenge
# (c) Dave Gust 1/2/2018
# request_client.rb
#

require 'net/https'
require 'uri'
require 'json'
require 'pathname'
my_path = Pathname.new(File.dirname(__FILE__) + '/../').realpath
$LOAD_PATH.push(my_path) unless $LOAD_PATH.detect { |p| p == my_path }
require 'user_config'
include AuroraSolar


module AuroraSolar

  # Builds and sends requests to solar installations
  class RequestClient

    # Sends a POST request to the Solar installation and returns the plant overview data
    # Params:
    #  - base_uri:      Override the configured Solar installation base URI string
    #  - id:            Override the configured Candidate Id string
    #  - password:      Override the configured Password MD5 Hex digest string
    # Returns the HTTPResponse object
    def plant_overview_request(base_uri=SOLAR_BASE_URI, id=CANDIDATE_ID, password=PASSWORD_MD5_HEX_DIGEST)
      # Append candidate id and password query parameters to the base URI path
      uri = URI(base_uri + "#{PLANT_PATH}?candidate=#{id}&password=#{password}")

      # Send the platform overview request and return the HTTPResponse object
      send_request(uri)
    end

    # Sends a POST request to the Solar installation and returns the entity data per the passed params
    # Params:
    #  - device_name:   The device name string
    #  - channel_name:  The channel name string
    #  - base_uri:      Override the configured Solar installation base URI string
    #  - id:            Override the configured Candidate Id string
    #  - password:      Override the configured Password MD5 Hex digest string
    # Returns the HTTPResponse object
    def entity_data_request(device_name, channel_name, base_uri=SOLAR_BASE_URI, id=CANDIDATE_ID, password=PASSWORD_MD5_HEX_DIGEST)
      # Append query parameters, including the entity and channel to the base URI path
      uri = URI(base_uri + "#{ENTITY_DATA}?candidate=#{id}&password=#{password}&entity=#{device_name}&channel=#{channel_name}")

      # Send the entity data request and return the HTTPResponse object
      send_request(uri)
    end

    # Sends a POST request to the Solar service
    # Params:
    #  - uri: The complete solar installation URI object (includes candidate id and password)
    # Returns the HTTPResponse object
    def send_request(uri)
      begin
        # Submit the POST SSL request
        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
          post_request = Net::HTTP::Post.new(uri)
          response = https.request post_request   # Net::HTTPResponse object

          #DEBUG
          #self.print_response(response)

          return response
        end
      rescue Exception => e
        error = "send_request: Error submitting request for URI '#{uri}': " + e.message
        puts error
        puts e.backtrace
        raise(error)
      end
    end


    # Helper method for printing HTTPResponse DEBUG
    def print_response(response)
      puts 'Mock Solar Service response status code: ' + response.code
      puts 'Mock Solar Service response status message: ' + response.message
      puts "Mock Solar Service response body:\n" + response.body + "\n"
    end

  end

end
