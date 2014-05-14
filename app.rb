require 'rubygems'
require 'sinatra'
require 'net/http'
require 'uri'
require 'json'
require 'echonest-ruby-api'
require "grooveshark"
require "rdio_api"


class API
  # Put your real iTunes API code here
  def self.echonest
    song = Echonest::Song.new('BIPUBB0USDUU2XMCL')

    params = { song_max_hotttnesss: "1", results: 10}
    #params = { rank_type: "familiarity"}
    song.search(params).map do |track|
       track[:title] + ": " + track[:artist_name]
    end 
  end

  def self.lastfm
    # Put your real LastFM code here
    
    api_key = "8161363efe3a0745d841750184887854"
    url = "http://ws.audioscrobbler.com/2.0/?method=chart.gettoptracks&api_key=#{api_key}&format=json&page=1&limit=10"

    url = URI.parse(url)
    json= Net::HTTP.get_response(url).body
    results = JSON.parse(json)
    songs = results["tracks"]["track"]
    #return songs
  	songs.map do |track|
   		  track["artist"]["name"] + ": " + track["name"]
    end
  end

  def self.grooveshark
    # Replace amazon with real API names and code
    
    client = Grooveshark::Client.new
 
    popular = client.popular_songs.uniq[0..9]
    songs = popular.map do |listing|
      song = listing.to_s.split(/ - /)[1]
    end
    artists = popular.map do |listing|
      artist = listing.to_s.split(/ - /)[2]
    end
    artists.zip(songs).map do |artist, song|
     "#{artist}: #{song}"
    end
  end
  
  def self.rdio
    client = RdioApi.new(:consumer_key => "qezrkgg3r52ttvvf42zk68fc", :consumer_secret => "YgbDv5j8CP")

    response = client.getTopCharts(:type => "Track")
    popular = response.map do |item|
      song = "#{item.artist}" ": " " #{item.name}"
    end[0..9]
  end
end

helpers do
  def get_all(wanted)
    results = []
    wanted.each do |api|
      results.concat(API.send(api.downcase.to_sym))
    end
    return results.uniq
  end
end


get '/' do
  erb :form
end

post '/' do
  @results = get_all(params[:wanted])
  erb :results
end

get '/about' do 
  erb :about
end

get '/faq' do
  erb :faq
end



