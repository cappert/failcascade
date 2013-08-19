class AlliancesController < ApplicationController
  before_filter :set_alliances, except: [:show]

  def index
    @alliances = @alliances.desc(:current_member_count)

    if params[:q].to_s.present?
      regex = /.*#{Regexp.escape params[:q].to_s.strip}.*/i
      @alliances = @alliances.or({ name: regex }, { ticker: regex })
    end

    respond_to do |format|
      format.html do
        if @alliances.size == 1
          redirect_to alliance_path(id: @alliances.first.ticker)
        end
      end
      format.json do
        render json: @alliances.map{ |alliance| { id: alliance.ticker, text: "#{alliance.name} <#{alliance.ticker}>" } }
      end
    end
  end

  def top_list
    @alliances = @alliances.desc(:current_member_count)
  end

  def growing
    @alliances = @alliances.gt(current_member_count: 100).desc(:growth_ratio, :current_member_count)
  end

  def collapsing
    @alliances = Alliance.all.ne(predicted_collapse: nil).asc(:predicted_collapse).desc(:current_member_count)
  end

  def show
    @alliance = Alliance.where(ticker: params[:id].to_s.upcase).first
  end

  protected

  def set_alliances
    @alliances = Alliance.all.limit(10)
  end
end
