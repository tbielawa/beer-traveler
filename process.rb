#!/usr/bin/ruby
require 'pp'
require 'json'

######################################################################
# Set user to argv
if ARGV.count >= 1
  USER = ARGV[0]
else
  USER = 'tbielawa'
end

SAMPLED_BREWERIES = {}
SAMPLED_COUNTRIES = {}


File.open("distinct_beers-#{USER}.json", 'r') { |file|
  distinct_beers = JSON.load(file)
  distinct_beers.each { |beer, details|
    brewery = details['brewery']
    brewery_name = brewery['brewery_name']
    brewery_country = brewery['country_name']

    # Track the countries we've had beers from in a dictionary
    # ("hash"). The key,value pairs are country=>{breweryN => count}
    #
    # If we've had beers from this country then the key will exist and
    # the value will be a hash. We'll just increment this breweries
    # count in that case if it exists, otherwise we'll add it with a
    # starting count of 1.
    #
    # If the country doesn't exist, then has_key? will be false. We'll
    # create the key/value pair as country=>{brewery => 1}.
    if SAMPLED_COUNTRIES.has_key?(brewery_country)
      # Use .merge! to reduce adding a new brewery and updating a
      # breweries counts into one action
      SAMPLED_COUNTRIES[brewery_country].merge!({brewery_name => 1}) { |key, v1, v2| v1 + v2 }
      # The {|| ...} block handles updating counts when the brewery is
      # already registered. It just adds the current value with the
      # new value (1).
    else
      SAMPLED_COUNTRIES[brewery_country] = {brewery_name => 1}
    end
  }
}

# Create a list of the countries which is sorted by the number of
# breweries sampled in each country.

# todo stuff


total_drinks = 0
SAMPLED_COUNTRIES.values.each { | breweries |
  total_drinks += breweries.values.reduce(0) { | sum, n | sum + n }
}
puts "Total Beers Drank: #{total_drinks} from #{SAMPLED_COUNTRIES.count} countries\n"

# Print the countries followed by the breweries in each country.

SAMPLED_COUNTRIES.each { |country, breweries|
  breweries_sampled = breweries.count
  # Sum the number of drinks/brewery for this country
  beers_drank_in_country = breweries.keys.reduce(0) { |sum, n| sum + breweries[n] }

  puts "#{country.upcase} - #{beers_drank_in_country} beers drank from #{breweries_sampled} breweries"
  breweries.each { |name, count|
    puts "- #{name} - #{count}"
  }
}
