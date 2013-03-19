require "sinatra"
require "feature"

dir = File.dirname(File.expand_path(__FILE__))

set :views,  "#{dir}/dashboard/views"
set :public_folder, "#{dir}/dashboard/public"


get "/" do
  @features = Feature.features
  erb :index
end