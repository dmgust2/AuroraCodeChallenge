#!/usr/bin/ruby
#
# Aurora coding challenge
# (c) Dave Gust 1/2/2018
# user_config.rb
#


module AuroraSolar

  # CONFIG: Users could define these values for using the lib without specifying each time
  SOLAR_BASE_URI          = 'https://aurorasolar-monitoring-task.herokuapp.com'   # Solar installation URI
  CANDIDATE_ID            = 'HBA516'                                              # User's candidate ID
  PASSWORD_MD5_HEX_DIGEST = '76adb77b86d44e7a9f6addde889553df'                    # User's password hashed via MD5

  PLANT_PATH              = '/plant_overview'
  ENTITY_DATA             = '/entity_data'

end
