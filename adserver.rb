require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'haml'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/adserver.db")

class Ad

  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :content, Text
  property :width, Integer
  property :height, Integer
  property :filename, String
  property :url, String
  property :is_active, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime
  property :size, Integer
  property :content_type, String

end

# create or upgrade all tables at once
DataMapper.auto_upgrade!

# set utf-8 for outgoing
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  @title = "Welcome to Matt's Ad Server"
  haml :welcome
end

get '/ad' do
end

get '/list' do
  @title = "All Ads"
  @ads = Ad.all(:order => [:created_at.desc])
  haml :list
end

get '/new' do
  @title = "Create a New Ad"
  haml :new
end

post '/create' do
  @ad = Ad.new(params[:ad])
  @ad.content_type = params[:image][:type]
  @ad.size = File.size(params[:image][:tempfile])

  if @ad.save
    path = File.join(Dir.pwd, "public/ads", @ad.filename)
    File.open(path, "wb") do |f|
      f.write(params[:image][:tempfile].read)
    end
    redirect "/show/#{@ad.id}"
  else
    redirect('/list')
  end

end

get '/delete/:id' do
  ad = Ad.get(params[:id])
  unless ad.nil?
    path = File.join(Dir.pwd, "/public/ads", ad.filename)
    File.delete(path)
    ad.destroy
  end
  redirect('/list')
end

get '/show/:id' do
  @ad = Ad.get(params[:id])
  @title = "#{@ad.title}"

  if @ad
    haml :show
  else
    redirect('/list')
  end

end

get '/click/:id' do
end