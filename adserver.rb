require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require './lib/authorization'

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

  # has many clicks
  has n, :clicks

  def handle_upload(file)
    self.content_type = file[:type]
    self.size = File.size(file[:tempfile])
    path = File.join(Dir.pwd, "public/ads", self.filename)
    File.open(path, "wb") do |f|
      f.write(file[:tempfile].read)
    end
  end

end

class Click

  include DataMapper::Resource

  property :id, Serial
  property :ip_address, String
  property :created_at, DateTime

  belongs_to :ad

end

# create or upgrade all tables at once
configure :development do
  DataMapper.auto_upgrade!
end

helpers do
  include Sinatra::Authorization
end

# set utf-8 for outgoing
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  @title = "Matt's Ad Server"
  haml :welcome
end

get '/demo' do
  erb :demo
end

get '/ad' do
  id = repository(:default).adapter.select(
    'SELECT id FROM ads ORDER BY random() LIMIT 1;'
  )
  @ad = Ad.get(id)
  erb :ad, :layout => false
end

get '/list' do
  require_admin
  @title = "All Ads"
  @ads = Ad.all(:order => [:created_at.desc])
  haml :list
end

get '/new' do
  require_admin
  @title = "Create a New Ad"
  haml :new
end

post '/create' do
  require_admin
  @ad = Ad.new(params[:ad])
  @ad.handle_upload(params[:image])
  if @ad.save
    redirect("/show/#{@ad.id}")
  else

  end

end

get '/delete/:id' do
  require_admin
  ad = Ad.get(params[:id])
  unless ad.nil?
    path = File.join(Dir.pwd, "/public/ads", ad.filename)
    File.delete(path)
    ad.destroy
  end
  redirect('/list')
end

get '/show/:id' do
  require_admin
  @ad = Ad.get(params[:id])
  @title = "#{@ad.title}"

  if @ad
    haml :show
  else
    redirect('/list')
  end

end

get '/click/:id' do
  ad = Ad.get(params[:id])
  ad.clicks.create(:ip_address => env["REMOTE_ADDR"])
  redirect(ad.url)
end