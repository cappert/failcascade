class AlliancesController < ApplicationController
  before_filter :allow_caching, only: [ :top_list, :growing, :collapsing, :show ]

  def index
    @alliances = Alliance.limit(10).desc(:current_member_count)

    if params[:term].to_s.present?
      regex = /.*#{Regexp.escape params[:term].to_s.strip}.*/i
      @alliances = @alliances.or({ name: regex }, { ticker: regex })
    end

    respond_to do |format|
      format.html do
        if @alliances.size == 1
          redirect_to alliance_path(id: @alliances.first.ticker)
        end
      end
      format.json do
        render json: @alliances.map{ |alliance| { value: alliance.ticker, label: alliance.full_name } }
      end
    end
  end

  def top_list
    @alliances = Alliance.noticeable.limit(10).desc(:current_member_count, :growth_ratio)
  end

  def growing
    @alliances = Alliance.noticeable.limit(10).gt(growth_ratio: 1).lt(growth_ratio: 5).desc(:growth_ratio, :current_member_count)
  end

  def collapsing
    @alliances = Alliance.noticeable.gt(peak_member_count: Alliance::SIGNIFICANT_SIZE * 2).ne(predicted_collapse: nil).asc(:predicted_collapse).desc(:current_member_count)
  end

  def landlords
    @alliances = Alliance.noticeable.limit(10).gt(sov_held: 0).desc(:sov_held, :current_member_count)
  end

  def show
    @alliance = Alliance.or({ticker: params[:id].to_s.upcase}, {_id: params[:id]}).first
    raise ActionController::RoutingError.new('Not Found') unless @alliance
  end
end
