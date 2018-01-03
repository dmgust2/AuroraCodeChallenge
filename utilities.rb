#!/usr/bin/ruby
#
# Aurora coding challenge
# (c) Dave Gust 1/2/2018
# utilities.rb
#

require 'json'
require 'pathname'
my_path = Pathname.new(File.dirname(__FILE__)).realpath
$LOAD_PATH.push(my_path) unless $LOAD_PATH.detect { |p| p == my_path }
require 'user_config'
include AuroraSolar


module AuroraSolar

  class Utilities

    # Retrieves a list of all the component device names currently in the configured/specified solar installation
    # Params:
    #  - base_uri:      Override the configured Solar installation base URI string
    #  - id:            Override the configured Candidate Id string
    #  - password:      Override the configured Password MD5 Hex digest string
    # Returns a list array of device name strings
    def self.get_all_devices(base_uri=SOLAR_BASE_URI, id=CANDIDATE_ID, password=PASSWORD_MD5_HEX_DIGEST)
      component_list = []

      # Send a POST request to get the list of components
      @request_client = RequestClient.new
      response = @request_client.plant_overview_request(base_uri, id, password)
      response_body = JSON.parse(response.body)

      # Parse the JSON response for individual devices
      response_body.each do |comp|
        if comp['type'] == 'Device'
          # Add the Device name to the list
          component_list << comp['device_name']
        end
      end

      return component_list
    end

    # Retrieves a list of channels for the specified device currently in the configured/specified solar installation
    # Params:
    #  - device_name:   The component device name string
    #  - base_uri:      Override the configured Solar installation base URI string
    #  - id:            Override the configured Candidate Id string
    #  - password:      Override the configured Password MD5 Hex digest string
    # Returns a list array of channel hashes (parameter, name, unit)
    def self.get_channels(device_name, base_uri=SOLAR_BASE_URI, id=CANDIDATE_ID, password=PASSWORD_MD5_HEX_DIGEST)
      # Send a POST request to get the list of components
      @request_client = RequestClient.new
      response = @request_client.plant_overview_request(base_uri, id, password)
      response_body = JSON.parse(response.body)

      # Parse the JSON response for the specified device channels
      response_body.each do |comp|
        if comp['type'] == 'Device' and comp['device_name'] == device_name
          # Return the list of channels for this device
          return comp['channels']
        end
      end

      puts "WARNING: No component found with device name '#{device_name}'!"
      return []
    end

    # Retrieves the channel data for the specified device and channel currently in the configured/specified solar installation
    # Params:
    #  - device_name:   The component device name string
    #  - channel_name:  The device's channel name string
    #  - base_uri:      Override the configured Solar installation base URI string
    #  - id:            Override the configured Candidate Id string
    #  - password:      Override the configured Password MD5 Hex digest string
    # Returns the channel data string
    def self.get_channel_data(device_name, channel_name, base_uri=SOLAR_BASE_URI, id=CANDIDATE_ID, password=PASSWORD_MD5_HEX_DIGEST)
      # Send a POST request to get the list of components
      @request_client = RequestClient.new
      response = @request_client.entity_data_request(device_name, channel_name, base_uri, id, password)
      JSON.parse(response.body)
    end


    # Determines the ​total​ ​amount​ ​of​ ​energy​ ​produced​ ​by​ ​the​ ​entire​ ​solar​ ​installation
    # Returns the total energy data string
    def self.get_total_energy
      self.get_channel_data('Plant', 'GriEgyTot').to_f
    end

    # Determines the ​total​ ​amount​ ​of​ ​energy​ ​produced​ ​by​ ​each​ ​inverter in the solar​ ​installation
    # Returns the total energy data (float)
    def self.get_total_inverter_energy
      # Get all the component devices
      devices = self.get_all_devices

      total_energy = 0.0
      # For each ​inverter (SI) device, get the total energy (E-Total channel data) and aggregate
      devices.each do |device|
        if device.start_with? 'SI'
          total_energy += self.get_channel_data(device, 'E-Total').to_f
        end
      end

      return total_energy
    end

    # Determines the average​ ​charge​ ​amount​ ​for​ ​each​ ​battery​ in the solar​ ​installation
    # Returns the average charge percentage (float)
    def self.average_battery_charge
      # Get all the component devices
      devices = self.get_all_devices

      total_charge = 0.0
      inverter_device_count = 0
      # For each ​device, get the battery charge (BatSoc channel data) and aggregate
      # NOTE: It looks to me like only inverters have a battery charge, so using only inverter devices like above
      devices.each do |device|
        if device.start_with? 'SI'
          total_charge += self.get_channel_data(device, 'BatSoc').to_f
          inverter_device_count += 1
        end
      end

      return total_charge/inverter_device_count
    end

  end

end
