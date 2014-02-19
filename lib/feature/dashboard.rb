require "sinatra/base"
require "feature"
require "feature/dashboard/helpers"

module Feature
  class Dashboard < Sinatra::Base

    dir = File.dirname(File.expand_path(__FILE__))

    set(:views, "#{dir}/dashboard/views")
    set(:public_folder, "#{dir}/dashboard/public")

    before do
      @features = ::Feature.features
    end

    # Features

    get "/" do
      erb(:index)
    end

    post "/features/:id/enable" do
      Feature(params[:id].to_sym).enable
      redirect to("/")
    end

    post "/features/:id/disable" do
      Feature(params[:id].to_sym).disable
      redirect to("/")
    end

    # Groups

    get "/groups/:id" do
      set_group
      @members = ::Feature.get_group_members(@group)
      @title = "group / #{@group}"
      erb(:group)
    end

    post "/groups/:id/members" do
      set_group
      member = params[:member]

      ::Feature.add_to_group(@group, member) if member.length > 0
      redirect to("/groups/#{@group}")
    end

    post "/groups/:id/members/:member/destroy" do
      set_group
      member = params[:member]

      ::Feature.remove_from_group(@group, member)
      redirect to("/groups/#{@group}")
    end

    private

    def set_group
      @group = params[:id].to_sym
    end
  end
end
