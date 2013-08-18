class AlliancesController < ApplicationController
  def index
    @alliances = Alliance.all
    if (search_term = params[:q].to_s.strip) && search_term.present?
      @alliances = @alliances.or({ name: /.*#{search_term}.*/i }, { ticker: /.*#{search_term}.*/i })
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
