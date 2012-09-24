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

    # Track the countries we've had beers from in a dictionary. The
    # key,value pairs are country=>{breweryN => count}
    #
    # is If we've had beers from this country then the key will exist
    # and the value will be a hash. We'll just increment this
    # breweries count.
    #
    # If the country doesn't exist, then has_key? will be false. We'll
    # create the key/value pair as country=>{brewery => 1}.
    if SAMPLED_COUNTRIES.has_key?(brewery_country)
      # Use .merge! to streamline adding a new brewery and updating a
      # breweries counts into one action
      SAMPLED_COUNTRIES[brewery_country].merge!({brewery_name => 1}) { |key, v1, v2| v1 + v2 }
      # The {|| ...} block handles updating counts when the brewery is
      # already registered. It just adds the current value with the
      # new value.
    else
      SAMPLED_COUNTRIES[brewery_country] = {brewery_name => 1}
    end
  }

  # Sorts the countries by number of breweries sampled and returns the
  # sorted results as a list.
  # sorted_countries = SAMPLED_COUNTRIES.keys.sort { |a, b|
  #   a_count = SAMPLED_COUNTRIES[a].count
  #   b_count = SAMPLED_COUNTRIES[b].count
  #   if a_count > b_count
  #     1
  #   elsif a_count == b_count
  #     0
  #   else
  #     -1
  #   end
  # }

  # Print the countries (sorted by amount sampled) followed by the
  # breweries in each country.
  SAMPLED_COUNTRIES.each { |country, breweries|
    breweries_sampled = breweries.count
    # Sum the number of drinks/brewery for this country
    beers_drank_in_country = breweries.keys.reduce(0) { |sum, n| sum + breweries[n] }

    puts "#{country.upcase} - #{beers_drank_in_country} beers drank from #{breweries_sampled} breweries"
    breweries.each { |name, count|
      puts "- #{name} - #{count}"
    }
  }
}
