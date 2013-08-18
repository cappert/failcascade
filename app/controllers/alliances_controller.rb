class AlliancesController < ApplicationController
  def index
    @alliances = Alliance.all.desc(:current_member_count).limit(25)
  end

  def show
    @alliance = Alliance.where(ticker: params[:ticker].to_s.upcase).first
  end
end
