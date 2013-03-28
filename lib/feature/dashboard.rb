require "sinatra/base"
require "feature"
require "feature/dashboard/helpers"

module Feature
  class Dashboard < Sinatra::Base

    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/dashboard/views"
    set :public_folder, "#{dir}/dashboard/public"

    before do
      @features = ::Feature.features
    end

    get "/" do
      erb :index
    end

    post "/:id/enable" do
      id = params[:id].to_sym
      @flash = "#{id} enabled" if Feature(id).enable
      erb :index
    end

    post "/:id/disable" do
      id = params[:id].to_sym
      @flash = "#{id} disabled" if Feature(id).disable
      erb :index
    end

  end
end