# wordcloud.rb
require 'rubygems'
require 'sinatra'
require 'lib/word_cloud/point.rb'
require 'lib/word_cloud/box.rb'
require 'lib/word_cloud/cloud.rb'
require 'lib/word_cloud/word.rb'
require 'lib/word_cloud/word_cloud.rb'
require 'rmagick'
require 'haml'
require 'sass'
require 'json'
require 'pp'

set :logging, :true

post '/' do
  format = params.delete("format")
  @debug = params.delete("debug")
  
  wc = WordCloud::WordCloud.new
  tags = {}
  if params[:text]
    params[:text].split(',').each do |item|
      tag, weight = item.strip.split(':')
      tags[tag] = weight.to_i
    end
  end
  params[:tag].each do |i, tag|
    tags[tag] = params[:weight][i].to_i if (tag and tag != "")
  end
  wc.setTags(tags)
  
  case format
  when "jpg"
    content_type "image/jpeg"
    @image = wc.getImage
    @image.format = "JPEG"
    @image.to_blob
  else
    @cloud = wc.getHTML
    @wc_dump = wc.pretty_inspect
    haml :cloud
  end
end

get '/' do
  haml :index
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end
