module Api
  class ProfilesController < ApplicationController
    
    def create
       profile = Profile.create!(profile_params)
       GithubProfileScrapeJob.perform_later(profile.id)
       render json: profile, status: :created
    end

    
    def index
      profiles = Profile.all
      render json: profiles
    end

    def show
      profile = Profile.find(params[:id])
      render json: profile
    end
  end
end
