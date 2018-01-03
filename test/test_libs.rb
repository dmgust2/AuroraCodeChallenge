#!/usr/bin/ruby
#
# Aurora coding challenge
# (c) Dave Gust 1/2/2018
# test_libs.rb
#

require 'minitest/autorun'
require 'json'
require 'awesome_print'
require 'pathname'
my_path = Pathname.new(File.dirname(__FILE__) + '/../').realpath
$LOAD_PATH.push(my_path) unless $LOAD_PATH.detect { |p| p == my_path }
require 'request_client'
require 'utilities'
require 'user_config'
include AuroraSolar


# Basic tests for AuroraSolar
class TestSolar < MiniTest::Unit::TestCase

  # Setup ran before every test execution
  def setup
    # Initialize the Aurora Solar Installation RequestClient
    @request_client = RequestClient.new
  end


  #
  # Request Client tests
  #

  def test_plant_overview_request
    print_test_separator('test_plant_overview_request')

    response = @request_client.plant_overview_request

    # Validate the response
    assert_equal('200', response.code)
    assert_equal('OK', response.message)
  end

  def test_entity_data_request
    print_test_separator('test_entity_data_request')

    test_device_name = 'SI5048EH:1260016316'
    test_channel_name = 'E-Total'
    response = @request_client.entity_data_request(test_device_name, test_channel_name)

    # Validate the response
    assert_equal('200', response.code)
    assert_equal('OK', response.message)
  end



  #
  # Utility method tests
  #

  def test_get_all_components
    print_test_separator('test_get_all_components')

    # Call the Util function
    list = Utilities::get_all_devices

    #DEBUG
    #ap list

    # Validate the expected component count
    assert_equal(8, list.count)
  end

  def test_get_channels
    print_test_separator('test_get_channels')

    test_device_name = 'SI5048EH:1260016316'

    # Call the Util function
    list = Utilities::get_channels(test_device_name)

    #DEBUG
    #ap list

    # Validate the expected component count
    assert_equal(120, list.count)
  end

  def test_bad_device_name
    print_test_separator('test_bad_device_name')

    test_device_name = 'foobar'

    # Call the Util function
    list = Utilities::get_channels(test_device_name)

    # Validate no channels are returned
    assert_empty(list)
  end

  def test_get_channel_data
    print_test_separator('test_get_channel_data')

    test_device_name = 'SI5048EH:1260016316'
    test_channel_name = 'E-Total'
    data = Utilities::get_channel_data(test_device_name, test_channel_name)

    # Validate the returned data value
    assert_equal('32283.0', data)
  end


  #
  # Bonus questions
  #

  def test_get_total_energy
    print_test_separator('test_get_total_energy')

    total_energy = Utilities::get_total_energy

    puts "The total energy produced​ ​by​ ​the​ ​entire​ (mock) ​solar​ ​installation: #{total_energy} kWh"

    # Validate the result
    assert_equal(63819.1, total_energy)
  end

  def test_get_total_inverter_energy
    print_test_separator('test_get_total_inverter_energy')

    total_energy = Utilities::get_total_inverter_energy

    puts "The ​total​ ​amount​ ​of​ ​energy​ ​produced​ ​by​ all​ ​inverters in the (mock) solar​ ​installation: #{total_energy} kWh"

    # Validate the result => 32283.0 + 31536.1 = 63819.1
    assert_equal(63819.1, total_energy)
  end

  def test_average_battery_charge
    print_test_separator('test_average_battery_charge')

    average_charge = Utilities::average_battery_charge

    puts "The ​average charge across all batteries in the (mock) solar​ ​installation: #{average_charge} %"

    # Validate the result => 65.5 + 66.3 = 65.9
    assert_equal(65.9, average_charge)
  end



  #
  # Helper methods
  #

  def print_test_separator(test_name)
    puts '.........................Running: ' + test_name + '.........................'
  end

end
