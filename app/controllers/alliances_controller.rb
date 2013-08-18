class AlliancesController < ApplicationController
  def index
    @alliances = Alliance.all
    if params[:q].to_s.present?
      regex = /.*#{Regexp.escape params[:q].to_s.strip}.*/i
      @alliances = @alliances.or({ name: regex }, { ticker: regex })
    end
    @alliances = @alliances.desc(:current_member_count).limit(10)

    respond_to do |format|
      format.html
      format.json do
        render json: @alliances.map{ |alliance| { id: alliance.ticker, text: "#{alliance.name} <#{alliance.ticker}>" } }
      end
    end
  end

  def show
    @alliance = Alliance.where(ticker: params[:ticker].to_s.upcase).first
  end
end
