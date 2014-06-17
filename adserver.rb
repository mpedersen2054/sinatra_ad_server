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
  @title = "Welcome"
  haml :welcome
end

get '/ad' do
end

get '/list' do
end

get '/new' do
end

post '/create' do
end

get '/delete/:id' do
end

get '/show/:id' do
end

get '/click/:id' do
end