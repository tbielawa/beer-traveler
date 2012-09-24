#!/usr/bin/ruby
require 'json'
require 'pp'
require 'rest-client'

######################################################################
# Set user to argv
if ARGV.count >= 1
  USER = ARGV[0]
else
  USER = 'tbielawa'
end
######################################################################
# Constants
OFFSET_INCREMENT = 25

######################################################################
# API Information
CLIENT_ID = #id
CLIENT_SECRET = #secret

######################################################################
# Resource information
U_BASE_REF = 'http://api.untappd.com/v4'
USER_BEER_LIST = "#{U_BASE_REF}/user/beers/#{USER}"

######################################################################
# Collectors for data retrieved
#
# Beers the users has drank. Should be a dictionary of beername =>
# beer information
DISTINCT_BEERS = {}
# Breweries the user has drank beer from. Big dictionaries.
SAMPLED_BREWERIES = {}
# Countries the user has has beer from. Just a dictionary, keys =
# country, values = counts
SAMPLED_COUNTRIES = {}

######################################################################
# Make requests for the initial user distinct beers
#
# Set the initial offset
o = 0
# Loop until we receive everything
while true
  # Increase the offset to fetch results up to
  o += OFFSET_INCREMENT

  # Use a 'begin ... rescue ... end' block because RestClient.get will
  # raise an error and stop the program. The 'rescue' part 'catches'
  # the error instead and lets us do something with it.

  begin
    r = RestClient.get USER_BEER_LIST, :params => {:client_id => CLIENT_ID, :client_secret => CLIENT_SECRET, :offset => o}
    result = JSON.load(r)
  rescue RestClient::InternalServerError => e
    # Turn the error message text (in JSON format) into actual ruby
    # objects
    err = JSON.load(e.response)
    puts "Error #{err['meta']['code']}: #{err['meta']['error_detail']}"

    # Get out of the while loop
    break
  end

  if result['meta']['code'] == 200
    beers = result['response']['beers']['items']
    if beers.count == 0
      break
    end
    beers.each do |beer|
      #pp beer['beer']
      beer_name = beer['beer']['beer_name']
      puts "Logging #{beer_name}"
      DISTINCT_BEERS[beer_name] = beer
    end 
  else
    break
  end
end

# Save results
File.open("distinct_beers-#{USER}.json", 'w') { |file| file.write(JSON.dump(DISTINCT_BEERS)) }

# Print out everything we did manage to get
pp DISTINCT_BEERS
######################################################################
# Collect data


######################################################################
# Process data into results


######################################################################
# Present results

